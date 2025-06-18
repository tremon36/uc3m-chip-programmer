import 'package:programmer/chip.dart';
import 'package:programmer/register.dart';
import 'dart:typed_data';

class RegisterList {

  static List<Chip> chipList = [];
  static List<Register> getChipRegisters(Chip c) {
    return chipList.firstWhere((tc) => tc.nameId == c.nameId).registers;
  }
  static Uint8List getSendData(Chip c) {
    List<Register> regList = c.registers;
    int bit_pointer;
    int data_current_index = 0;
    int total_bit = 0;
    int total_data = 0;
    
    for (Register r in regList) {
      total_bit = total_bit + r.nbits;
    }

    int spare_bit = 0;

    if(total_bit % 8 != 0) {
      total_data = total_bit ~/ 8 + 1;
      spare_bit = 8-(total_bit % 8);
    } else total_data = total_bit ~/ 8;

    List<int> data = List.filled(total_data, 0);

    bit_pointer = 7-spare_bit;
    
    for (Register reg in regList) {
      int current_reg_bit_pointer = 0;
      while(current_reg_bit_pointer < reg.nbits) {
        int will_be_inserted = (((reg.value & (1 << current_reg_bit_pointer))>>>current_reg_bit_pointer)<<bit_pointer);
        data[data_current_index] = data[data_current_index] | (((reg.value & (1 << current_reg_bit_pointer))>>>current_reg_bit_pointer)<<bit_pointer);
        current_reg_bit_pointer++;
        bit_pointer--;
        if(bit_pointer == -1){
          bit_pointer = 7;
          data_current_index++;
        }
      }
    }
    return Uint8List.fromList(data);
  }

}