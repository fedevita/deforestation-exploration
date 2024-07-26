# Deforestation Exploration
## UDACITY - SQL - Nanodegree Program

### Setting Up the Environment

To set up the environment, you can use either of the following scripts:

- `start-compose.ps1`
- `start-compose.sh`

Launch the script with different parameters as follows:

```sh
start-compose.ps1 -Profile start
start-compose.ps1 -Profile import
```

or

```sh
./start-compose.sh start
./start-compose.sh import
```

### Accessing the Database

1. **Open your web browser** and go to [http://localhost:80](http://localhost:80).

2. **Log in to pgAdmin** using the following credentials:
   - **User**: user@domain.com
   - **Password**: admin

### Setting Up the Database Connection in pgAdmin

3. Use the following parameters to configure the connection:
   - **Host**: deforestation-exploration-db
   - **Port**: 5432
   - **Database**: postgres
   - **Username**: postgres
   - **Password**: mysecretpassword

### Querying the Preloaded Database

Once pgAdmin is set up, you can query the preloaded database using the provided datasets.