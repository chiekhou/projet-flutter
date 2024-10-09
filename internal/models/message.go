package models

import (
	"time"

)

type Message struct {
    ID             uint      `json:"id" gorm:"primaryKey"`
    ExpediteurID   uint      `json:"expediteur_id" binding:"required"`
    DestinataireID uint      `json:"destinataire_id" binding:"required"`
    Contenu        string    `json:"contenu" binding:"required"`
    Date           time.Time `json:"date"`
    Lu             bool      `json:"lu"`
    Expediteur     User      `json:"-" gorm:"foreignKey:ExpediteurID"`
    Destinataire   User      `json:"-" gorm:"foreignKey:DestinataireID"`
}
