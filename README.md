## Description
This is a POC of StreamSets Data Collector on Docker for the Innive framework

## Source
The Dockerfile and its related information is from streamsets/datacollector-kubernetes: https://github.com/streamsets/datacollector-kubernetes  
While there is a Streamsets Docker repo, the Dockerfile from the kubernetes repo is closer to what we need for the Innive framework.

The Docker repo can be found here: https://github.com/streamsets/datacollector-docker

## Changes
Explanation of changes to the original Dockerfile should be detailed here (easier to find than surfing commits).  Yes I know that is the point of version control  

- Updated version from 2.6.0.0 to 3.11.0
  - this will need to be managed as new SDC versions are rolled out.  
- Removed Kafka, AWS, and stats packages from install
  - stats package should come with the core install; may need to add back  
- Added jdbc and google packages to install
  - streamsets-datacollector-jdbc-lib
