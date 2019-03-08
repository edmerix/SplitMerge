# SplitMerge
My GUI for the manual stage of spike sorting with [UltraMegaSort2000](https://github.com/danamics/UMS2K) (UMS)

This tool depends on the original UMS toolbox from the [Kleinfeld lab](https://neurophysics.ucsd.edu/software.php)

To speed up interactivity, I'm making use of the new UIFigure and UIAxes objects (most importantly the scrollable features) and thus it requires Matlab version >= R2018a. It should be small tweaks to remove native scrolling to work on earlier versions, but channels with large numbers of clusters may become laggy.

It is designed to work on directories containing UMS result structs for each channel in many files, speeding up processing of large numbers of channels, such as in the Utah array.

__N.B.__ This is a work in progress...  Importantly, I have made _minor_ alterations to the original toolbox, which _may_ be required for full functionality. These requirements will be removed/documented shortly (see todos below).

_BTW_ this uses Matlab's class structure (using @ClassName directory and separate methods files within). This structure must be maintained in order for the methods to work correctly.

### Todos:
- [ ] Remove or document all necessary alterations to the base UMS toolbox
- [ ] Write the help documentation!
- [x] Add app.Data.modifylist array for future use (minimizing replots)
- [ ] Update the replotting of the Inspect/merge panel to make use of app.Data.modifylist data and avoid full re-plot
- [ ] Add in confirmation of file change when alterations have been made (use app.Data.modified array?)
