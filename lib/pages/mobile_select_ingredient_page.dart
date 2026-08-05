import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';

class MobileSelectIngredientPage extends StatefulWidget {
  final RawDataInfo? initialSelected;

  const MobileSelectIngredientPage({
    super.key,
    this.initialSelected,
  });

  @override
  State<MobileSelectIngredientPage> createState() => _MobileSelectIngredientPageState();
}

class _MobileSelectIngredientPageState extends State<MobileSelectIngredientPage> {
  RawDataInfo? _selectedRaw;

  @override
  void initState() {
    super.initState();
    _selectedRaw = widget.initialSelected;
    if (_selectedRaw == null && rawDataList.isNotEmpty) {
      _selectedRaw = rawDataList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RawDataInfo> itemsToDisplay = rawDataList;
    if (itemsToDisplay.isEmpty) {
      itemsToDisplay = List.generate(14, (index) {
        String idStr = (index + 1).toString().padLeft(2, '0');
        return RawDataInfo(
          materialId: idStr,
          materialName: 'Ingredient $idStr',
          ingredient: 'Environmentally friendly, pure natural, and pollution-free rice',
          recId: index + 1,
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Select Ingredient',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: itemsToDisplay.length,
                  itemBuilder: (context, index) {
                    RawDataInfo raw = itemsToDisplay[index];
                    String displayId = (raw.materialId != null && raw.materialId!.isNotEmpty)
                        ? raw.materialId!
                        : (index + 1).toString().padLeft(2, '0');
                    bool isSelected = _selectedRaw?.materialId == raw.materialId;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRaw = raw;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF004884)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          displayId,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Confirm Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _selectedRaw == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedRaw);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004884),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
