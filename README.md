# SplitMerge
My GUI for the manual stage of spike sorting with [UltraMegaSort2000](https://github.com/danamics/UMS2K) (UMS)

This tool depends on the original UMS toolbox from the [Kleinfeld lab](https://neurophysics.ucsd.edu/software.php)

__N.B.__ This is a work in progress...  Importantly, I have made _minor_ alterations to the original toolbox, which _may_ be required for full functionality. These requirements will be removed/documented shortly (see todos below).

### Todos:
- [ ] Remove or document all necessary alterations to the base UMS toolbox
- [x] Add app.Data.modifylist array for future use (minimizing replots)
- [ ] Update the replotting of the Inspect/merge panel to make use of app.Data.modifylist data and avoid full re-plot
- [ ] Add in confirmation of file change when alterations have been made (use app.Data.modified array?)
