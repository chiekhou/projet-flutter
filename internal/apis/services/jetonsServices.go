package services

import (
	"errors"
	"example/hello/internal/initializers"
	"example/hello/internal/models"

	"gorm.io/gorm"
)

func UpdateStandStock(tx *gorm.DB, standID uint, change int) error {
	// Récupérer le stand avec ses stocks
	var stand models.Stand
	if err := tx.Preload("Stocks").First(&stand, standID).Error; err != nil {
		return errors.New("stand not found")
	}

	// Vérifier si le stand a des stocks
	if len(stand.Stocks) == 0 {
		return errors.New("no stock items for this stand")
	}

	// Mettre à jour le premier stock (vous pouvez ajuster cette logique selon vos besoins)
	stock := &stand.Stocks[0]
	newQuantity := stock.Quantite + change
	if newQuantity < 0 {
		return errors.New("insufficient stock")
	}

	// Mettre à jour la quantité
	stock.Quantite = newQuantity
	if err := tx.Save(stock).Error; err != nil {
		return err
	}

	return nil
}

func AttributePointsToUser(eleveID uint, points int) error {
	var eleve models.Eleve
	if err := initializers.DB.First(&eleve, eleveID).Error; err != nil {
		return errors.New("user not found")
	}

	eleve.PointsAccumules += points
	return initializers.DB.Save(&eleve).Error
}

func GetUserByID(userID uint) (*models.User, error) {
	var user models.User
	result := initializers.DB.First(&user, userID)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, result.Error
	}

	return &user, nil
}
