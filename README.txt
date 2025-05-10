In main.m, you can select which point of the flight envelope you want to simulate.

From there, you can call most of the other .m files that you see defined. I recommend looking into those functions to see what it needs passed as an input. Notably, some of the LMIs struggled with minimizing over gamma, so an upper bound was set on gamma and was manually, iteravely tweaked lower until CVX start reporting status: failed. If you are working with a model that I did not simulate, then you'll have to do the same. Unless you can figure out why CVX is struggling with the min problem.

hinfoutputcontrol.m unfortunately was never operational. I was running into dimensional issues with the final step of defining AK, BK, CK, and DK. The step where I calculate AK2, BK2, CK2, and DK2 was not a square output, which really seems wrong to me. That is probably where the error lies.

Files project_progress.m, re_figure7.m, and basic_analysis.mlx were created for the project progress report and were not designed to be called from main. 

input-multi-main.py and trascribe.py were used to digitalize the F100 models. These were "vibe coded" so it's really not great, but it was good enough.
