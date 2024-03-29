[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3951171.svg)](https://doi.org/10.5281/zenodo.3951171)

### _Note: MatLab ≥ r2020a occasionally breaks button positioning on small screens — the branch at [GridLayout](https://github.com/edmerix/SplitMerge/tree/GridLayout) implements full resizable elements and fixes that issue, however it has undergone limited testing as of Apr 2021_

# SplitMerge
My GUI for the manual stage of spike sorting with [UltraMegaSort2000](https://github.com/danamics/UMS2K) (UMS).

If you use this software in your work, please cite both the original UMS2000 toolbox (Hill DN, Mehta SB, Kleinfeld D. *"Quality metrics to accompany spike sorting of extracellular signals"* __J Neurosci__, 2011) and this software (Merricks EM, *"SplitMerge toolbox: a fast GUI for UltraMegaSort2000"* __DOI:10.5281/zenodo.3951171__, 2020)

## Quickstart
Download the most recent [release](https://github.com/edmerix/SplitMerge/releases) and install the app in Matlab by opening "SplitMerge.mlappinstall". The app can now be started by clicking on its button in the "Apps" tab at the top of the Matlab main window.

Alternatively, add the source code directory to your Matlab path, and enter `SplitMerge` in the command window. `app = SplitMerge();` will enable a handle to interact with the GUI programmatically, and allows for name, value pairs of arguments to be passed to the app from the following options:

|       Name |                                                          Description                                                         | Default |
|-----------:|:-----------------------------------------------------------------------------------------------------------------------------|---------|
|  Directory | Immediately open the specified directory (can be changed in-app)                                                             | ''      |
|   DateSort | Sort files by how recently they were modified                                                                                | false   |
|   SizeSort | Sort files by how large they are                                                                                             | false   |
| Fullscreen | Start app in fullscreen mode                                                                                                 | false   |
|     Height | Start app with this height (pixels)                                                                                          | 900     |
|      Width | Start app with this width (pixels)                                                                                           | 1440    |
|  TreeWidth | Set the left column (file list) to this width (pixels)                                                                       | 200     |
|      Epoch | Lock time plots to these start and stop times (seconds). If empty, defaults to earliest and latest spikes in selected channel | []      |
|   ShowTime | Show seconds on time plots                                                                                                   | false   |
|   Colorful | Plot units with different colors (can be toggled in-app)                                                                     | true    |
|    ToScale | Plot units on the same scale (can be toggled in-app)                                                                         | false   |
|       nFFT | Length to use for FFT calculation in Noise Removal tab                                                                       | 8192    |
|  Debugging | Show verbose messages about functioning to command window                                                                    | false   |

## Info

__UPDATE 2020-09-28__: [Keyboard shortcuts](#keyboard-shortcuts)! And a new figure for quick overview of waveshape similarities between multiple pairs of clusters.

__UPDATE 2020-07-14__: Major overhaul of the main plot method giving a huge increase in the speed of loading units.

[Screenshots below](#screenshots).

This tool depends on the original UMS toolbox from the [Kleinfeld lab](https://neurophysics.ucsd.edu/software.php)

To speed up interactivity, I'm making use of the new UIFigure and UIAxes objects (most importantly the scrollable features) and thus it requires Matlab version >= R2018b. It should be small tweaks to remove native scrolling to work on earlier versions, but channels with large numbers of clusters may become laggy.

It is designed to work on directories containing UMS result structs for each channel in many files, speeding up processing of large numbers of channels, such as in the Utah array.

## Screenshots:

__Inspect/Merge tab:__

![Screenshot of SplitMerge in Inspect/Merge mode](Screenshots/Inspect.png?raw=true "Inspect/Merge tab")

__Split tab:__

![Screenshot of SplitMerge in Split mode](Screenshots/Split.png?raw=true "Split tab")

__Outliers tab:__

![Screenshot of SplitMerge in Outlier mode](Screenshots/Outliers.png?raw=true "Outliers tab")

__Noise removal tab:__

![Screenshot of SplitMerge in Noise Removal mode](Screenshots/Noise.png?raw=true "Noise removal tab")

## Keyboard shortcuts:

<sub><sup>Icons: ⌃ = ctrl key, ⇧ = shift key</sup></sub>

### Global shortcuts

|  Key |                   Action                  | Alternate keys |
|-----:|:-----------------------------------------:|----------------|
|    s | Save file                                 |                |
|   ⌃1 | Activate inspect/merge tab                | ⌃i _or_ ⌃m     |
|   ⌃2 | Activate split tab                        | ⌃t             |
|   ⌃3 | Activate outliers tab                     | ⌃o             |
|   ⌃4 | Activate details tab _(empty at present)_ | ⌃d             |
|   ⌃5 | Activate PCA tab                          | ⌃p             |
|   ⌃6 | Activate de-noise tab                     | ⌃n             |
|   ⌃r | Refresh screen                            |                |
| ⌃esc | Attempt unhang                            |                |

### Tab-specific shortcuts

<table>
<thead>
  <tr>
    <th>Tab</th>
    <th>Key</th>
    <th>Action</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="7">Inspect/Merge</td>
    <td>g</td>
    <td>Mark selected as good</td>
  </tr>
  <tr>
    <td>b</td>
    <td>Un-mark selected as good</td>
  </tr>
  <tr>
    <td>c</td>
    <td>Compare waveforms from selected clusters</td>
  </tr>
  <tr>
    <td>⇧c</td>
    <td>Compare selected pairs with mean ± 2SD shaded plots</td>
  </tr>
  <tr>
    <td>p</td>
    <td>Plot the PCA</td>
  </tr>
  <tr>
    <td>m</td>
    <td>Merge the selected clusters</td>
  </tr>
  <tr>
    <td>t</td>
    <td>Move the selected clusters to the trash</td>
  </tr>
  <tr>
    <td rowspan="6">Split</td>
    <td>↑</td>
    <td>Move the threshold up one value</td>
  </tr>
  <tr>
    <td>⇧↑</td>
    <td>Move the threshold up by 5% of the range</td>
  </tr>
  <tr>
    <td>↓</td>
    <td>Move the threshold down one value</td>
  </tr>
  <tr>
    <td>⇧↓</td>
    <td>Move the threshold down by 5% of the range</td>
  </tr>
  <tr>
    <td>p</td>
    <td>Prune aggregation tree</td>
  </tr>
  <tr>
    <td>x</td>
    <td>Execute split</td>
  </tr>
  <tr>
    <td rowspan="5">Outliers</td>
    <td>←</td>
    <td>Move the threshold in by 1</td>
  </tr>
  <tr>
    <td>⇧←</td>
    <td>Move the threshold in by 5% of the range</td>
  </tr>
  <tr>
    <td>→</td>
    <td>Move the threshold out by 1</td>
  </tr>
  <tr>
    <td>⇧→</td>
    <td>Move the threshold out by 5% of the range</td>
  </tr>
  <tr>
    <td>c</td>
    <td>Cut waveforms</td>
  </tr>
</tbody>
</table>

### Todos:
- [x] Remove or document all necessary alterations to the base UMS toolbox
- [ ] Write the more in-depth help documentation!
- [x] Add app.Data.modifylist array for future use (minimizing replots)
- [x] Update the replotting of the Inspect/merge panel to make use of app.Data.modifylist data and avoid full re-plot
- [x] Add in confirmation of file change when alterations have been made (use app.Data.modified array?)
- [x] Occasionally marking a unit as "good" results in multiple entries in the labels structure – update setLabel method to check for these
- [ ] Update to use uigridlayout for all panels
- [x] Add "compare pairs" figure for quick overview of waveshape similarities between multiple pairs of clusters
- [x] Add keyboard shortcuts
