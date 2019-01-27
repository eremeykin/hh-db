import psycopg2

URL = "jdbc:postgresql://localhost:5432/bestjobs"

DB_NAME = "bestjobs"
USER = "postgres"
PASSWORD = "postgres"
HOST = "localhost"


class Migration:
    LIMIT = 10000
    SQL = {'account': '''
                WITH ins AS (
                  INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
                  SELECT login, password, first_name, family_name, contact_email, contact_phone FROM tmp_account ORDER BY account_id DESC OFFSET {offset} LIMIT {limit}
                  RETURNING account_id
                )
                INSERT INTO map_account (new_id)
                SELECT account_id FROM ins;''',
           'job': '''
                WITH ins AS (
                  INSERT INTO job (title,city, description, salary)
                  SELECT title,city, description, salary FROM tmp_job ORDER BY job_id DESC OFFSET {offset} LIMIT {limit}
                  RETURNING job_id
                )
                INSERT INTO map_job (new_id)
                SELECT job_id FROM ins;           
           ''',
           'company': '''
                WITH ins AS (
                  INSERT INTO company (name)
                  SELECT name FROM tmp_company ORDER BY company_id DESC OFFSET {offset} LIMIT {limit}
                  RETURNING company_id
                )
                INSERT INTO map_company (new_id)
                SELECT company_id FROM ins;           
           '''
           }

    def __init__(self):
        self.connection = psycopg2.connect(host=HOST, database=DB_NAME, user=USER, password=PASSWORD)

    def rows_count(self, table):
        cur = self.connection.cursor()
        cur.execute('SELECT COUNT(*) FROM {table_name}'.format(table_name=table))
        return cur.fetchone()[0]

    def migrate_table(self, table):
        cur = self.connection.cursor()
        total_in_tmp = self.rows_count('tmp_{table_name}'.format(table_name=table))
        offset = 0
        while self.rows_count(table) < 0.01 * total_in_tmp:
            print(offset)
            cur.execute(Migration.SQL[table].format(offset=offset, limit=Migration.LIMIT))
            offset += Migration.LIMIT
            conn.commit()


if __name__ == "__main__":
    conn = psycopg2.connect(host=HOST, database=DB_NAME, user=USER, password=PASSWORD)
    migration = Migration()
    migration.migrate_table('account')
    migration.migrate_table('job')
    migration.migrate_table('company')
