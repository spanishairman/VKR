<?php
// Zabbix GUI configuration file.
global $DB, $HISTORY;

$DB['TYPE']				= 'Postgresql';
$DB['SERVER']			= 'localhost';
$DB['PORT']				= '0';
$DB['DATABASE']			= 'zabbix';
$DB['USER']				= 'zabbix';
$DB['PASSWORD']			= '********';
// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA']			= '';

$ZBX_SERVER				= 'localhost';
$ZBX_SERVER_PORT		= '10051';
$ZBX_SERVER_NAME		= '';

$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//$HISTORY['url']   = [
//		'uint' => 'http://localhost:9200',
//		'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//$HISTORY['types'] = ['uint', 'text'];
