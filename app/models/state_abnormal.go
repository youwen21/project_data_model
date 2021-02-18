package models

type StateAbnormal struct {
	AbnormalType    int       `xorm:"default 0 INT(11)"`
	CreatedAt       DateTime `xorm:"default 'CURRENT_TIMESTAMP' DATETIME"`
	DbName          string    `xorm:"default '' VARCHAR(255)"`
	DeletedAt       DateTime `xorm:"DATETIME"`
	EventType       int       `xorm:"default 0 INT(11)"`
	FieldName       string    `xorm:"default '' VARCHAR(255)"`
	IsDeleted       int       `xorm:"default 0 TINYINT(4)"`
	StateAbnormalId int       `xorm:"not null pk autoincr INT(11)"`
	StateFrom       string    `xorm:"VARCHAR(255)"`
	StateTo         string    `xorm:"VARCHAR(255)"`
	TableName       string    `xorm:"default '' VARCHAR(255)"`
	UpdatedAt       DateTime `xorm:"default 'CURRENT_TIMESTAMP' DATETIME"`
}