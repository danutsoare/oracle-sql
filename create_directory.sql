/*
#
#       Script pentru crearea unui director in baza de date Oracle folosit de utilitarul datapump.
#       Autor: Danut Soare
#       Versiune: 01
#
*/

SET SERVEROUTPUT ON
SET VERIFY OFF
SET LINES 300
COL directory_name FORMAT a30
COL directory_path FORMAT A60


PROMPT Introduceti directorul unde vor fi salvate obiectele bazei de date (ex. C:\backupdb sau /home/oracle/backupdb):  

CREATE OR REPLACE DIRECTORY export_dir AS '&&director';
GRANT READ,WRITE ON DIRECTORY export_dir TO public;

PROMPT Noul director a fost creat:

SELECT directory_name,directory_path FROM dba_directories WHERE directory_path = '&&director';


PROMPT Se verifica daca exista drepturi de scriere pe noul director!  

declare
   fhandle  utl_file.file_type;
 begin
   fhandle := utl_file.fopen(
                 'EXPORT_DIR'     
               , 'test_file.txt' 
               , 'w' 
                   );
   utl_file.put(fhandle, 'FooBar!');
   utl_file.fclose(fhandle);
 exception
   when others then
     dbms_output.put_line('ERROR: ' || SQLCODE|| ' - ' || SQLERRM);
     raise;
 end;
 /
