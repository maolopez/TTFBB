<h1># Time_during_Broken_Builds</h1>
Time between broken build to the build once it is fixed for first time.


For example:
For builds in Jenkins measures the distance between the first sucessful build in a block of *consecutive* successful builds and the first failed build in a block of *consecutive* failed builds. The table below is based on a Jenkins job that is scheduled every 5 minutes:


|*Build Number*|*Result* |*Time to Fix a Broken Build*|*Debuging*                                |
| -------------|:-------:| --------------------------:|-----------------------------------------:|
| 12422        | SUCCESS |    600 seconds             |one-build-success-after-2-fail.tx         |
| 12421        | FAILURE |                            |                                          |
| 12420        | FAILURE |                            |                                          |
| 12419        | SUCCESS |                            |                                          |
| 12418        | SUCCESS |                            |                                          |
| 12417        | SUCCESS |    300 seconds             |2-builds-succeded-after-one-fail-debug.txt|
| 12416        | FAILURE |                            |only-latest-build-fails-debug.txt         |
| 12415        | SUCCESS |                            |                                          |
