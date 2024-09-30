package models

type Gagnant struct {
	ID        uint `gorm:"primary_key" json:"id"`
	UserID    uint
	User      User
	TombolaID uint
	Tombola   Tombola
	LotID     uint
	Lot       Lot
	TicketID  uint
	Ticket    Ticket
}
