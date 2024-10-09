package models

import (
	"time"
)

type TransactionType string

const (
	TransactionTypeAchat       TransactionType = "ACHAT"
	TransactionTypeUtilisation TransactionType = "UTILISATION"
	TransactionTypeTransfert   TransactionType = "TRANSFERT"
)

type JetonTransaction struct {
	ID          uint `gorm:"primary_key" json:"id"`
	UserID      uint
	User        User
	Montant     int64
	Type        TransactionType
	Description string
	StandID     *uint
	Stand       *Stand
	Date        time.Time
	PaiementID  string
}
