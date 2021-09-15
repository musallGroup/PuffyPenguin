# Printed Circuit Boards and build instructions

## Changing the printed circuit boards

The LED panel PCB was created fully in KiCAD because it is opensource. We used SeeedStudio to manufacture the circuit boards. A list of components is linked here.

### Generating gerber and drill files from KiCAD

 To get the PCB printed you may want to regenerate the GERBER and drill files.

This is how to do it to print in seeedstudio:

 - go to *File* -> *Plot*
 - select the **output directory**, plot format: **Gerber**
 - select layers: **F.Cu; B.Cu; B.SilkS;F.SilkS;B.Mask;F.Mask;Edge.Cuts**
 - select options: **Plot footprint values**; **Plot footprint references**; **Exclude PCB edge layer from other layers**; **Default line width (mm): 0.1**
 - gerber options: **Use protel filename extensions** and Format: 4.6 (unit mm)
 - clicking Plot will generate the Gerber files; to gererate drill files click *drill file*
 - Select **Merge PTH and NPTH into one file.** Unit: **milimeters** ; **suppress leading zeros** ; **PostScript** format; **Absolute origin**.

