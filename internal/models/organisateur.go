package models

type Organisateur struct {
	ID              uint       `gorm:"primary_key" json:"id"`
	UserID          uint       `gorm:"uniqueIndex"`
	User            User       `gorm:"constraint:OnDelete:CASCADE;"`
	KermessesGerees []Kermesse `gorm:"many2many:organisateur_kermesses;"`
}
