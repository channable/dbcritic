# dbcritic

dbcritic finds problems in a database schema.

## Synopsis

To run dbcritic, set the environment variables expected by [libpq][libpqenv].
Then invoke dbcritic with no arguments.
For instance:

```console
$ export PGHOST=localhost
$ export PGPORT=5432
$ export PGUSER=myuser
$ export PGDATABASE=mydatabase
$ dbcritic
```

[libpqenv]: https://www.postgresql.org/docs/current/libpq-envars.html

## Description

dbcritic connects to a PostgreSQL database using the specified parameters.
It then performs a series of checks and reports discovered issues.
Issues may result from the cluster configuration or from the database schema.

dbcritic implements the following checks:

    TODO: Generate this part of the documentation the list of checks.
    TODO: Each check already has an identifier and a help text.

## Configuration

dbcritic can be configured with a file _.dbcriticrc_ in the working directory.

dbcritic will ignore any empty lines and comment lines in the file.
Comment lines begin with a hash sign (#).

dbcritic can be configured to silence certain issues with _silence_ directives.
Any issue whose identifier begins with the given prefix will not be reported.
Here is an example of a silence directive:

```
silence index_fk_ref cache_log
```

This will silence any issues reported by the _index\_fk\_ref_ check
that pertain to the _cache\_log_ table.

## Exit status

If any issues were reported, dbcritic exits with status code 1.
If an unrecoverable error occurred, dbcritic exits with status code 2.
In any other case, dbcritic exits with status code 0.

# Bugs

The output is quite verbose and repetitive.
Experienced users may favor more compact output.
This is currently not implemented.

In the check _index\_fk\_ref_, the order of the columns in the suggested index
is not always correct.

There are many more opportunities for checks.
