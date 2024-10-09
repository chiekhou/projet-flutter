package models

type Tombola struct {
	ID         uint `gorm:"primary_key" json:"id"`
	Nom        string `json:"nom"`
	KermesseID uint `json:"kermesse_id"`
	Lots       []Lot `json:"lots"`
	Tickets    []Ticket `json:"tickets"`
}
