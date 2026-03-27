# Changelog

based off of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project attempts to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

 
  
## [1.1.1] 2026-03-27

### Added

  - Added this changelog

### Changed

  - Modified body text of digest to have two tables, one a listing of urls and another of summary by hostname 


## [1.1.0] 2026-03-25

### Added 

  - database-service container to store events
  - cleanup-service container to clean out older events
  - digest-service container to email a "digest" of previous day activity
  - event-listener-service records incoming events

### Removed
  - email-service container removed and functionality split between digest-service, event-listener-service and database

### Changed

Instead of emailing aas events received, will send a daily digest.

## [1.0.0] 2026-02-11

## Added 

The initial system was rolled out, a set of containers that would send an email when the ezproxy needhosts.htm page was triggered. Also included code to generate the needhosts.htm file and some instructions. 


## pre 2026-02-25

Not covered by this document