SET DEFINE ~
DELETE FROM gps_unit WHERE oid_gps_provider = 1002;

INSERT INTO GPS_UNIT
  (
    oid_gps_provider,
    truck_number,
    first_name,
    last_name,
    current_location,
    entry_date,
    external_power,
    connect_status,
    current_latitude,
    current_longitude,
    position_last_changed_date
  )
SELECT
  GPS_PROVIDER_ID, 
  TRAILER_NUMBER, 
  'UNKNOWN',
  'UNKNOWN',
  LAST_LOCATION, 
  EVENT_TIME, 
  EXTERNAL_POWER,
  EXTERNAL_POWER,
  LATITUDE,
  LONGITUDE,
  POSITION_LAST_CHANGED_DATE
FROM GPS_UNIT_IMPORT;

COMMIT
