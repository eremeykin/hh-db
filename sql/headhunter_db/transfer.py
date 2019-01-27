import psycopg2
import re
from functools import lru_cache

URL = "jdbc:postgresql://localhost:5432/bestjobs"

DB_NAME = "bestjobs"
USER = "postgres"
PASSWORD = "postgres"
HOST = "localhost"


class Migration:
    LIMIT = 1000

    def __init__(self):
        self.connection = psycopg2.connect(host=HOST, database=DB_NAME, user=USER, password=PASSWORD)
        with open('transfer.sql', 'r') as sql_file:
            self.sql_file = sql_file.read()

    def rows_count(self, table):
        cur = self.connection.cursor()
        cur.execute('SELECT COUNT(*) FROM {table_name}'.format(table_name=table))
        res = cur.fetchone()[0]
        print('row_count {table_name}={res}'.format(table_name=table, res=res))
        return res

    @lru_cache(100)
    def get_sql(self, key):
        return re.search(r'-- {key}[\s\S]+?--'.format(key=key), self.sql_file).group()

    def migrate_table(self, table):
        cur = self.connection.cursor()
        total_in_tmp = self.rows_count('tmp_{table_name}'.format(table_name=table))
        offset = 0
        while offset < total_in_tmp:
            print(table+', offset = ' + str(offset))
            sql = self.get_sql(table)
            new_lim = 'OFFSET {offset} LIMIT {limit}'.format(offset=offset, limit=Migration.LIMIT)
            sql = re.sub(r'OFFSET \d+ LIMIT \d+', new_lim, sql)
            print(sql)
            cur.execute(sql)
            offset += Migration.LIMIT
            self.connection.commit()


if __name__ == "__main__":
    migration = Migration()
    migration.migrate_table('account')
    migration.migrate_table('job')
    migration.migrate_table('company')
    migration.migrate_table('hr_manager')
    migration.migrate_table('applicant')
    migration.migrate_table('vacancy')
    migration.migrate_table('resume')
    migration.migrate_table('message')
    migration.migrate_table('read_message')

