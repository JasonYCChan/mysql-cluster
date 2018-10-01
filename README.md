# install mysql-cluster7.5 on linux

## prepare setting
1. modify: config.ini
NDB_MGMD = 管理節點 private ip
NDBD = 資料節點 private ip
MYSQLD = SQL節點 private ip

2. modify: my.cnf
ndb-connectstring=管理節點 private ip

## Precautions
1. 執行shell必須跟 xx.sh同一層
2. 使用root權限 sudo su

## install 
1. use: sudo su
2. in mgm VM
> bash mgm_node.sh
3. in data node VM
> bash data_node.sh
4. in SQL node VM
> bash sql_node_part1.sh
### note: 有多台SQL node, --initialize也只能在某一台執行一次...不然之後會登不進去...
> /usr/local/mysql/bin/mysqld --initialize #記住密碼，之後登入後修改(第6步驟)
> bash sql_node_part1.sh
5. in mgm VM
> /usr/local/bin/ndb_mgm
> ndb_mgm> show
# you will see below message :
-- NDB Cluster -- Management Client --
ndb_mgm> show
Connected to Management Server at: localhost:1186
Cluster Configuration
---------------------
[ndbd(NDB)]     2 node(s)
id=2    @172.31.17.59  (mysql-5.7.23 ndb-7.5.11, Nodegroup: 0, *)
id=3    @172.31.30.100  (mysql-5.7.23 ndb-7.5.11, Nodegroup: 0)

[ndb_mgmd(MGM)] 1 node(s)
id=1    @172.31.20.244  (mysql-5.7.23 ndb-7.5.11)

[mysqld(API)]   1 node(s)
id=4    @172.31.27.63  (mysql-5.7.23 ndb-7.5.11)

6. 更新SQL node 密碼
> /usr/local/mysql/bin/mysql -uroot -p
> ${password} #手動執行後產出的密碼
> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Qwer0987!!'; #更新密碼
> exit
> ./mysql -uroot -p
> use mysql;
> UPDATE user SET HOST = '%' WHERE USER ='root';
> exit

## 必要概念及相關指令
1. 啟動Cluster順序 Manager node > Data node > SQL node。
如果是第一次啟動 SQL node 請使用 –initial 初始化，如果已經有資料請絕對不要使用 –initial 否則此 node 的資料全毀
2. 各節點啟動命令
Manager node：/usr/local/bin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini --initial # 第一次使用 or config.ini有改才需要加--initial
Data node：/usr/local/bin/ndbd
SQL node：/etc/rc.d/init.d/mysql.server start

3. 查詢指令 check command
ps aux | grep ndb #查詢node是否執行
ps aux | grep mysql #查詢mysql是否執行
kill -p ${PID} #刪掉process

4. 匯入資料庫(ndbcluster): cluster 的資料庫類型都必須為 ndbcluster，在匯入資料庫前必須改為 NDBCLUSTER
```bash=
# Type=InnoDB
$ mysqldump -uroot -p db | sed 's/ENGINE=InnoDB/ENGINE=NDBCLUSTER/g' > db.sql
or
# Type=MyISAM
$ mysqldump -uroot -p db | sed 's/ENGINE=MyISAM/ENGINE=NDBCLUSTER/g' > db.sql
```

## 測試項目
容錯測試

Data node1 中斷，服務正常
SQL node1 中斷，服務正常
Manage node 中斷，服務正常
Data node1 > SQL node1 順序中斷，服務正常
Data node1 > SQL node1 > Manage node 順序中斷，服務正常
Manage node > Data node1 順序中斷，服務異常
Manage node > SQL node1 順序中斷，服務異常
從上面測試可以理解，由於 Manage node 是所有 node 的管理者，一旦管理者掛了又觸發了容錯事件，就會無法處理而造成 cluster 中斷
 
這篇到結尾，如果你要基本的容錯機制可以允許一台故障的話，至少要 3 台才能建立起 MySQL Cluster 架構
Node1 (SQL + Data node)
Node2 (SQL + Data node)
Node3 (Manage node)
必須注意只擁有一台 Manage node 不能與其他的 node 共用，否則會同時觸發 Manage + node 異常而造成無法容錯的狀況。

這樣的架構還可以在無限延伸，包含 Manage node 也可以擁有多台進行容錯。

