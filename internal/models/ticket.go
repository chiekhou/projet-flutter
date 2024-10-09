package models

type Ticket struct {
	ID           uint `gorm:"primary_key" json:"id"`
	TombolaID    *uint
	Tombola      Tombola
	UserID       uint
	User         User
	Numero       string
	EstGagnant   bool
	PrixEnJetons int
}
