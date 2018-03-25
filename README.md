
To run, make sure you have AWS credentials available somewhere (through EC2 metadata or ~/.aws/credentials), then:

```
$ docker-compose up
```

Then, in a second terminal:

```
$ docker exec -it pg-server gosu postgres watch -n 1 "psql -c 'insert into foo default values;'"
```

This will write to the DB constantly so that we get lots of transactions to archive. Check the output in terminal 1 to see that it's successfully archiving to S3.

Then, in a third terminal run this several times, waiting for a few WAL segments to pass in between each run:

```
$ docker exec -it pg-server gosu postgres wal-g backup-push /var/lib/postgresql/data
```

Finally, run:

```
$ docker exec -it pg-server gosu postgres wal-g delete retain 1 --confirm
BUCKET: wal-g-issue-81
SERVER:
2018/03/25 16:49:21 base_000000010000000000000019 skipped
2018/03/25 16:49:21 base_000000010000000000000015 will be deleted
2018/03/25 16:49:21 base_000000010000000000000011 will be deleted
```

Now check the S3 bucket. All but the latest backup have been correctly deleted, but the sentinel files remain. Verify:

```
$ docker exec -it pg-server gosu postgres wal-g backup-list                      
BUCKET: wal-g-issue-81                                                           
SERVER:                                                                          
name    last_modified   wal_segment_backup_start                                 
base_000000010000000000000011   2018-03-25T16:48:22Z    000000010000000000000011 
base_000000010000000000000015   2018-03-25T16:48:37Z    000000010000000000000015 
base_000000010000000000000019   2018-03-25T16:48:51Z    000000010000000000000019 
```