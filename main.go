package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/bwmarrin/discordgo"
)

var token string
var game string
var imageDir string

func init() {
	flag.StringVar(&token, "t", "", "Bot Token")
	flag.StringVar(&game, "g", "", "Game")
	flag.StringVar(&imageDir, "d", "./images", "Image directory")
	flag.Parse()
}

func main() {
	if token == "" {
		fmt.Println("No token provided. Please run: roni -t <bot token>")
		return
	}

	// Create a new Discord session using the provided bot token.
	dg, err := discordgo.New("Bot " + token)
	if err != nil {
		fmt.Println("Error creating Discord session: ", err)
		return
	}

	// Register ready as a callback for the ready events.
	dg.AddHandler(ready)

	dg.AddHandler(messageCreate)

	// Open a websocket connection to Discord and begin listening.
	err = dg.Open()
	if err != nil {
		fmt.Println("error opening connection,", err)
		return
	}

	// Wait here until CTRL-C or other term signal is received.
	fmt.Println("Bot is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt, os.Kill)
	<-sc

	// Cleanly close down the Discord session.
	dg.Close()
}

// This function will be called (due to AddHandler above) when the bot receives
// the "ready" event from Discord.
func ready(s *discordgo.Session, event *discordgo.Ready) {

	// Set the playing status.
	s.UpdateStatus(0, game)
}

// This function will be called (due to AddHandler above) every time a new
// message is created on any channel that the autenticated bot has access to.
func messageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {

	// Ignore all messages created by the bot itself
	// This isn't required in this specific example but it's a good practice.
	if m.Author.ID == s.State.User.ID {
		return
	}

	if strings.HasPrefix(m.Content, "!roni") {
		files, err := ioutil.ReadDir(imageDir)
		randomImageIndex := rand.Intn(len(files))
		fileName := files[randomImageIndex].Name()
		filePath := filepath.Join(imageDir, fileName)
		if err != nil {
			panic(err)
		}
		f, err := os.Open(filePath)
		if err != nil {
			return
		}
		defer f.Close()
		ms := &discordgo.MessageSend{
			Embed: &discordgo.MessageEmbed{
				Image: &discordgo.MessageEmbedImage{
					URL: "attachment://" + fileName,
				},
			},
			Files: []*discordgo.File{
				&discordgo.File{
					Name:   fileName,
					Reader: f,
				},
			},
		}
		s.ChannelMessageSendComplex(m.ChannelID, ms)

	}
}
