To execute them, you need to have Docker and Docker Compose installed, as well as Bash.

To use the entire automation, a few steps are needed beforehand:
Choose a location and clone the repo.
Enter the created directory and execute the following commands( they grand execution right to the script without administrative privilege ).

chmod +x logger.sh
chmod +x runScript.sh
chmod +x script.sh
chmod +x createLogDirs.sh

After setting the permissions, you can enter config.json and configure the queries with which you want to retrieve data from your collection in Mongo. Currently, uniqueness can be ensured by only one field. The name of the key in config.json

You also need to create a .env file that contains the following keys:
DATABASE_URL='' (The address to the database, for example, localhost:27017/myDB) mongodb:// is preset in the file when creating the address.
DATABASE_NAME='' (The name of the database you want to filtered)
COLLECTION_NAME='' (The name of the collection you want to filter)

After that, in the current directory, you can choose ./runScript.sh and check if the following are created:
- A Reports folder is created with files in it.
- A logs.txt file is created with logs recorded in it.
- A logs.log file is created for errors during the execution of the scripts.
If these are in place, everything is set up correctly and working.
You can add ./runScript.sh to a cron job, and it will execute exactly on schedule!
