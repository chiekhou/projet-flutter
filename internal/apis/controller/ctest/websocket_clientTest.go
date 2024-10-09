package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"

	"github.com/gorilla/websocket"
)

type Message struct {
	ContenuMessage string `json:"contenu_message"`
	DestinataireID uint   `json:"destinataire_id"`
	ExpediteurID   uint   `json:"expediteur_id"`
}

func main() {
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	url := "ws://localhost:8080/api/ws/1"
	fmt.Printf("Connexion à %s...\n", url)

	c, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		log.Fatal("Erreur lors de la connexion:", err)
	}
	defer c.Close()

	done := make(chan struct{})

	go func() {
		defer close(done)
		for {
			_, message, err := c.ReadMessage()
			if err != nil {
				log.Println("Erreur de lecture:", err)
				return
			}
			fmt.Printf("Message reçu: %s\n", message)
		}
	}()

	go func() {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			text := scanner.Text()
			msg := Message{
				ContenuMessage: text,
				DestinataireID: 2, // ID du destinataire (à adapter selon vos besoins)
				ExpediteurID:   1, // ID de l'expéditeur (à adapter selon vos besoins)
			}
			jsonMsg, err := json.Marshal(msg)
			if err != nil {
				log.Println("Erreur lors de la création du JSON:", err)
				continue
			}
			err = c.WriteMessage(websocket.TextMessage, jsonMsg)
			if err != nil {
				log.Println("Erreur lors de l'envoi du message:", err)
				return
			}
			fmt.Println("Message envoyé.")
		}
	}()

	for {
		select {
		case <-done:
			return
		case <-interrupt:
			fmt.Println("Interruption reçue, fermeture...")
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("Erreur lors de l'envoi du message de fermeture:", err)
			}
			select {
			case <-done:
			}
			return
		}
	}
}
