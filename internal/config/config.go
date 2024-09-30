package config

import (
	"log"
	"os"

	"github.com/lpernett/godotenv"
)

type Config struct {
	WebURL     string
	AndroidURL string
	IOSURL     string
	//JWT        JwtConfig
	Env string `env:"ENV" envDefault:"development"`
}

/*type JwtConfig struct {
	SecretKey string `env:"SECRET_KEY"`
}*/

var AppConfig *Config

func LoadConfig() {
	env := os.Getenv("ENV")
	if env == "" {
		env = "development"
	}

	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	if env == "development" {
		AppConfig = &Config{
			WebURL:     os.Getenv("WEB_URL_DEV"),
			AndroidURL: os.Getenv("ANDROID_URL_DEV"),
			IOSURL:     os.Getenv("IOS_URL_DEV"),
		}
	} else {
		AppConfig = &Config{
			WebURL:     os.Getenv("WEB_URL_PROD"),
			AndroidURL: os.Getenv("ANDROID_URL_PROD"),
			IOSURL:     os.Getenv("IOS_URL_PROD"),
		}
	}
}
