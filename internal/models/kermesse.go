package models

import (
	"time"

	"gorm.io/gorm"
)

type Kermesse struct {
	gorm.Model
	ID             uint `gorm:"primary_key" json:"id"`
	Nom            string
	Date           time.Time
	Lieu           string
	Organisateurs  []Organisateur `gorm:"many2many:organisateur_kermesses;"`
	Participants   []User         `gorm:"many2many:kermesse_participants;"`
	Stands         []Stand
	PlanInteractif string   // JSON ou chemin vers le fichier
	Tombola        *Tombola `gorm:"constraint:OnDelete:SET NULL;"`
}
