package common

import (
	"crypto/rand"
	"math/big"
)

func GenerateRandomNumber(min, max int64) (int64, error) {
	// Calcule la plage
	rangeSize := big.NewInt(max - min + 1)

	// Génère un nombre aléatoire sécurisé entre 0 et rangeSize-1
	randomBig, err := rand.Int(rand.Reader, rangeSize)
	if err != nil {
		return 0, err
	}

	// Ajoute le min pour obtenir un nombre dans la plage [min, max]
	return randomBig.Int64() + min, nil
}
