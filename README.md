# CDCTables
Pull data from RxNorm and RxClass APIs to produce preliminary tables for the CDC opioid database

## Package the executable jar file with dependencies
```
mvn package
```

## Generate the data for load using the jar
Make sure the config folder is in directory where the jar is (for now).
```
java -jar CDCTables-*.jar
```
## Load the data to the opioid database
The script will pull the source data from the directory it is run
```
mysql --local-infile=1 -u root -p opioid < load_opioid_data.sql
```
