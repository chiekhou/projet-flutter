package models

type Gagnant struct {
    ID        uint `gorm:"primary_key" json:"id"`
    UserID    uint `json:"userId"`
    User      User `json:"user"`
    TombolaID uint `json:"tombolaId"`
    Tombola   Tombola `json:"tombola"`
    LotID     uint `json:"lotId"`
    Lot       Lot `json:"lot"`
    TicketID  uint `json:"ticketId"`
    Ticket    Ticket `json:"ticket"`
}