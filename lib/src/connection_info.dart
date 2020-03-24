class DBConnectionInfo {
  DBConnectionInfo(
      {this.driver,
      this.host,
      this.port,
      this.database,
      this.username,
      this.password,
      this.charset,
      this.schemes,
      this.prefix,
      this.sslmode});
  String prefix = '';
  String sslmode = 'prefer';
  String driver = 'pgsql';
  String host = 'loalhost';
  int port = 5432;
  String database = 'postgres';
  String username = '';
  String password = '';
  String charset = 'utf8';
  List<String> schemes = ['public'];
}
