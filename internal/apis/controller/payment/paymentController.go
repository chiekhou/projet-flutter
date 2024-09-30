package payment

import (
	"fmt"
	"io/ioutil"

	"log"
	"net/http"
	"os"

	"github.com/stripe/stripe-go"
	"github.com/stripe/stripe-go/paymentintent"
	"github.com/stripe/stripe-go/paymentmethod"
	"github.com/stripe/stripe-go/v72/webhook"
)

func ProcessPayment(amount int64, currency string, cardToken string) (string, error) {
	// Configurez votre clé secrète Stripe

	stripe.Key = os.Getenv("STRIPE_KEY")

	pm, err := paymentmethod.New(&stripe.PaymentMethodParams{
		Type: stripe.String(string(stripe.PaymentMethodTypeCard)),
		Card: &stripe.PaymentMethodCardParams{
			Token: stripe.String(cardToken),
		},
	})

	if err != nil {
		return "", fmt.Errorf("erreur lors de la création du PaymentMethod: %v", err)
	}

	// Créer un PaymentIntent en utilisant le PaymentMethod
	params := &stripe.PaymentIntentParams{
		Amount:             stripe.Int64(amount),
		Currency:           stripe.String(currency),
		PaymentMethod:      stripe.String(pm.ID),
		Confirm:            stripe.Bool(true),
		PaymentMethodTypes: []*string{stripe.String("card")},
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		return "", fmt.Errorf("erreur lors de la création du PaymentIntent: %v", err)
	}

	if pi.Status == stripe.PaymentIntentStatusRequiresAction {
		return pi.ClientSecret, nil
	}

	if pi.Status == stripe.PaymentIntentStatusSucceeded {
		return pi.ID, nil
	}

	return "", fmt.Errorf("statut de paiement inattendu: %s", pi.Status)
}

func HandleStripeWebhook(w http.ResponseWriter, req *http.Request) {
	// Log all headers
	log.Println("Received headers:")
	for name, headers := range req.Header {
		for _, h := range headers {
			log.Printf("%v: %v\n", name, h)
		}
	}

	// Read the body
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		log.Printf("Error reading request body: %v\n", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	// Log the body
	log.Printf("Received body: %s\n", string(body))

	// Verify payload is not empty
	if len(body) == 0 {
		log.Println("Received empty payload")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Get the signature from header
	signatureHeader := req.Header.Get("Stripe-Signature")
	if signatureHeader == "" {
		log.Println("Stripe-Signature header is missing")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Get the webhook secret from environment variable
	endpointSecret := os.Getenv("STRIPE_WEBHOOK_SECRET")
	if endpointSecret == "" {
		log.Println("Stripe webhook secret is not set")
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Construct the event
	event, err := webhook.ConstructEvent(body, signatureHeader, endpointSecret)
	if err != nil {
		log.Printf("Error verifying webhook signature: %v\n", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Process the event
	switch event.Type {
	case "payment_intent.succeeded":
		log.Println("Payment succeeded!")
	case "payment_intent.payment_failed":
		log.Println("Payment failed!")
	default:
		log.Printf("Unhandled event type: %s\n", event.Type)
	}

	w.WriteHeader(http.StatusOK)
}
