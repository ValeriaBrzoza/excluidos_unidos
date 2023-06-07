import 'package:flutter/material.dart';

class CustomSwitchListTile extends StatelessWidget {
  const CustomSwitchListTile({
    super.key,
    required this.label,
    required this.value,
    this.description,
    this.onChanged,
    this.onTap,
  });

  final String label;
  final String? description;
  final bool value;
  final void Function(bool)? onChanged;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      //fila
      mainAxisAlignment: MainAxisAlignment.spaceBetween, //va a separar cada elemento de la fila
      children: [
        Expanded(
          //ocupa todo ancho posible (por ser fila)
          child: InkWell(
            //detecta tap y le da el efecto del fondo al hacerlo
            onTap: onChanged != null ? onTap : null,
            child: SizedBox(
              //altura de la fila
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, //centra elementos columna
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 17, color: onChanged == null ? Colors.black45 : null)),
                  if (description != null) Text(description!, style: TextStyle(fontSize: 12, color: Colors.black45))
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
