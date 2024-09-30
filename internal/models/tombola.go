package models

type Tombola struct {
	ID         uint `gorm:"primary_key" json:"id"`
	Nom        string
	KermesseID uint
	Lots       []Lot
	Tickets    []Ticket
}
