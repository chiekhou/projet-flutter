package models

type Lot struct {
	ID          uint `gorm:"primary_key" json:"id"`
	TombolaID   uint
	Tombola     Tombola
	Nom         string
	Description string
	Valeur      float64
}
