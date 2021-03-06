package common

import (
	"fmt"
	"os"
	"owen2020/cmd/command/mysqlutil"
	"owen2020/conn"
	"regexp"
	"strings"
)

//TableColumnIdentify 表字段ID对应字段名
type TableColumnIdentify map[int]string

//DBTable  数据库.数据表map类型
type DBTable map[string]TableColumnIdentify

var (
	//Filter 定义过滤
	Filter string = ""

	// DBTables 数据库.数据表map配置实例
	DBTables DBTable = DBTable{}
)

func InitDBTables() {
	gorm := conn.GetSyncerGorm()

	dbs := mysqlutil.GetDBs(gorm)

	for _, db := range dbs {
		if db == "" {
			continue
		}
		FlushDBTables(db)
	}
}

func FlushDBTables(db string) {
	tables := mysqlutil.GetTableNames(conn.GetSyncerGorm(), db)
	for _, v := range tables {
		FlushTableIdentifierNameMap(db, v)
	}
}

// https://dev.mysql.com/doc/refman/8.0/en/identifiers.html
func FlushTableIdentifierNameMap(db string, table string) {
	ok := FilterTable(db, table)
	if !ok {
		return
	}

	sql := "show full columns from `" + table + "` from `" + db + "`"
	// sql := "show full FIELDS from `user` from `codeper`"

	results := []map[string]interface{}{}

	gorm := conn.GetSyncerGorm()

	err := gorm.Raw(sql).Find(&results).Error
	if err != nil {
		fmt.Println(err)
		return
	}

	// apputil.PrettyPrint(results)
	columns := TableColumnIdentify{}
	for i, v := range results {
		columns[i] = v["Field"].(string)
	}

	DBTables[db+"."+table] = columns
}

//FilterTable 检查table 是否在正则中
func FilterTable(db string, table string) bool {
	if true == SkipTable(db, table) {
		return false
	}

	filters := strings.Split(Filter, ",")
	for _, v := range filters {
		ok, _ := regexp.Match(v, []byte(db+"."+table))
		if ok {
			return true
		}
	}

	return false
}

func SkipTable(db string, table string) bool {
	if db == os.Getenv("DB_EVENT_DATABASE") {
		return true
	}

	if db == "mysql" {
		return true
	}

	return false
}
