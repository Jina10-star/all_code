# from workbench script blissplace_add_new_place_edits.ipynb
#       https://workbench.uberinternal.com/file/6231ad9a-45c8-40dc-991d-d23aa55e775f
# given a CSV in HDFS, add it to map_creation.blissplace_edits
# then update and backfill map_creation.blissplace_trips_to_edited_places

import datetime
import os
import utils
from pyspark import SparkConf, SparkContext
from pyspark.sql import HiveContext


conf = (SparkConf().setAppName("Add new BlissPlace edits to Hive"))
sparkContext = SparkContext(conf=conf)
spark = HiveContext(sparkContext)

script_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(script_path)

spark.sql("SET hive.exec.dynamic.partition.mode=nonstrict")
spark.sql("SET hive.exec.dynamic.partition=true")

hdfs_base_path = "hdfs:///user/lyanez/blissplace/chunchen_places_suggestedit/"

# csv_date = "2017-12-06_2018-02-04.csv"
# task_end_date = "2018-02-06"
#
# csv_date = "2017-12-13_2018-02-11.csv"
# task_end_date = "2018-03-08"
#
# csv_date = "2018-02-25_2018-03-04.csv"
# task_end_date = "2018-03-13"
#
# csv_date = "2018-03-04_2018-03-18.csv"
# task_end_date = "2018-03-23"
#
# csv_date = "2018-03-18_2018-03-25.csv"
# task_end_date = "2018-03-30"
#
# csv_date = "2018-03-25_2018-04-01.csv"
# task_end_date = "2018-04-09"
#
# csv_date = "2018-04-01_2018-04-15.csv"
# task_end_date = "2018-04-26"
#
# csv_date = "2018-04-15_2018-04-29.csv"
# task_end_date = "2018-05-07"
#
# csv_date = "prophecy_2018-03-18_2018-03-25.csv"
# task_end_date = "2018-04-02"
#
# csv_date = "prophecy_2018-03-25_2018-04-01.csv"
# task_end_date = "2018-04-05"
#
# csv_date = "prophecy_2018-04-01_2018-04-15.csv"
# task_end_date = "2018-04-26"

csv_date = "prophecy_2018-04-15_2018-04-29.csv"
task_end_date = "2018-05-07"


# add edits from a specific csv file to map_creation.blissplace_edits
edits_uploader = utils.BlissEditsUploader(hdfs_base_path=hdfs_base_path, csv_file_name=csv_date,
                                          task_end_date=task_end_date, spark=spark)
edits_uploader.add_data_to_edits_table()


# backfill map_creation.blissplace_trips_to_edited_places starting with task_end_date up to present day
start_date = task_end_date
end_date = utils.date_to_str(datetime.datetime.now() - datetime.timedelta(days=1))

trips_updater = utils.TripsUpdater(start_date, end_date, spark)
trips_updater.update_trips_table()
