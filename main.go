package main

import (
	_ "example/hello/docs"
	"example/hello/internal/apis/controller/kermesses"
	"example/hello/internal/apis/router"
	"example/hello/internal/config"
	"example/hello/internal/initializers"
	"log"
	"os"
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"github.com/caarlos0/env/v6"
	"github.com/lpernett/godotenv"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

var stripeKey string

func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDatabase()

}

// @title The Better Backend Template
// @version 0.1
// @description An example template of a Golang backend API
// @license.name MIT
// @BasePath /
func main() {

	server := gin.Default()

	// Chargement du fichier .env
	if err := godotenv.Load(); err != nil {
		log.Fatalf("Erreur lors du chargement du fichier .env : %v", err)
	}

	// Configuration de l'application
	var cfg config.Config
	if err := env.Parse(&cfg); err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Configurer les routes
	router.PublicRoutes(server)
	router.UserRoutes(server)
	router.KermesseRoutes(server)
	router.StandRoutes(server)
	router.TombolaRoutes(server)
	router.StockRoutes(server)
	router.JetonsTransactionRoutes(server)
	router.MessageRoutes(server)
	router.SetupStripeWebhookRoute(server)
	router.ParentRoutes(server)

	// Configuration des proxys de confiance
	trustedProxiesEnv := os.Getenv("TRUSTED_PROXIES")
	var trustedProxies []string
	if trustedProxiesEnv != "" {
		trustedProxies = strings.Split(trustedProxiesEnv, ",")
	}
	if err := server.SetTrustedProxies(trustedProxies); err != nil {
		log.Fatalf("Erreur lors de la configuration des proxys de confiance : %v", err)
	}

	// Configuration CORS
	allowedOrigins := os.Getenv("ALLOWED_ORIGINS")
	origins := strings.Split(allowedOrigins, ",")
	corsConfig := cors.Config{
		AllowOrigins:     origins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		AllowCredentials: true,
	}
	server.Use(cors.New(corsConfig))

	server.Static("/assets", "./assets")

	kermesses.InitializeKermessePlans()

	err := kermesses.InitKermessePlans()
	if err != nil {
		log.Fatalf("Failed to load kermesse plans: %v", err)
	}

	// Configuration de Swagger
	server.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	server.Use(gin.Logger())
	server.Use(gin.Recovery())

	// Lancer le serveur
	if err := server.Run(":8080"); err != nil {
		panic(err)
	}
}
