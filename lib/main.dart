import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' as platform;

final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

main() => runApp(const InvoicePrinterApp());

final invoiceData = <String, dynamic>{
  'companyInfo': {
    'companyName': 'AFRAM COMPANY LTD',
    'addressSpecific': '15 SENCHI STREET',
    'addressGeneral': 'AIRPORT RESIDENTIAL, ACCRA',
    'companyLogo': 'assets/images/slack.png',
  },
  'invoiceInfo': {
    'TIN': 'C000316699X',
    'INVOICE NO': ' NS198380',
    'DATE': '3rd Jul 2024',
    'CASHIER': 'Sarah Commey',
    'CURRENCY': 'GHS',
    'LINE ITEMS' : '3',
  },
  'items': [
    {'Item': 'SAMSUNG 43" FHD TV SAMSUNG 43" FHD TV', 'Qty': 1, 'Price': 2900.00,'Amount' : 2900.00},
    {'Item': 'TV WALL MOUNT', 'Qty': 2, 'Price': 200.00,'Amount' : 400.00,},
    {'Item': 'LG 55" 4K TV', 'Qty': 1, 'Price': 7500.00,'Amount' : 7500.00,},
  ],
  'breakdown': {
    'SUBTOTAL': 10800.00,
    'DISCOUNT': 0.00,
    'NHIL(2.5%)': 1.00,
    'GETFUND(2.5%)': 1.00,
    'COVID(1%)': 1.00,
    'VAT(15%)': 1.00,
  },
  'total': 10800.00,
  'sdcInfo': {
    'SDC ID': 'EV-24543-001',
    'ITEM COUNT': 3,
    'RECEIPT NUMBER': 5434322,
    'RECEIPT DATE & TIME': 'WED 3RD JUL 2024, 11:00 AM',
    'MRC': '00:0C:34:31:43:D0',
    'INTERNAL DATA': '3JHJ-B3NK-J4N3-NB33-MNJ3-HGF3',
    'SIGNATURE': '3425-533N-NJ33-1NBN'
  },
  'qrcode': 'https://evat-ng-verification-staging.vat-gh.com/?data=ix80f3EQvchR3Oxkl3PFNPjMEF17NvrEg/V5mmoSOqmHlZAvD6GskR2nz23xKktNzQgVPCVBMlMu1sA55c7nGgoFEYGmDJNkgIy75kaNx0KALL6ZNKbvjHN7nDnoD1VnZtZdAOxtE9Yz5Li5M8jzky5DkabZyyh2mPAXNtzgdOcaLzr0VzORGnEMWDrZEm9SgW/1FDTYHbyg0CM/+Gv2i1UhnNEQIFUN8VR4pFbmOTONqkE5daUxJIPhCIRZBWSc81nXK6nwLUvjLf7e9XE8zpUAue4BqzPuwhUa/b1NXG2TphXQFjgE2RCgNhHrPf1PRqix9PFkIgeEjnWFO9E4og==&v=1.1&t=w'
};

class InvoicePrinterApp extends StatelessWidget {
  const InvoicePrinterApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvoicePrinterApp',
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          appBarTheme: AppBarTheme(
              backgroundColor: colorScheme.inversePrimary
          )
      ),
      home: const InvoicePage(),
    );
  }
}

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Printer'),
        actions: [
          IconButton(onPressed: () async {
            final imageData = await platform.rootBundle.load(
                invoiceData['companyInfo']['companyLogo']);
            final icon = pw.MemoryImage(imageData.buffer.asUint8List());
            final pdf = pw.Document();
            final headLine = pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 8);
            final subHeadline = pw.TextStyle(
                fontWeight: pw.FontWeight.normal, fontSize: 6);
            final entries = invoiceData['invoiceInfo'].entries.toList();
            final qrCode = QrCode.fromData(
              data: invoiceData['qrcode'],
              errorCorrectLevel: QrErrorCorrectLevel.H,
            );

            final qrImage = QrImage(qrCode);
            final qrImageBytes = await qrImage.toImageAsBytes(
              size: 128,
              format: ImageByteFormat.png,
              decoration: const PrettyQrDecoration(),
            );
            pdf.addPage(pw.Page(
                pageFormat: PdfPageFormat.roll80,
                build: (pw.Context context) {
                  return pw.Column(
                      children: [
                  pw.Align(
                  alignment: pw.Alignment.center,
                      child: pw.Image(icon, height: 16, width: 16)
                  ),
                  pw.SizedBox(height: 4),
                  pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(invoiceData['companyInfo']['companyName'],
                  textAlign: pw.TextAlign.center,
                  style: headLine),
                  ),
                  pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(invoiceData['companyInfo']['addressSpecific'],
                  textAlign: pw.TextAlign.center,
                  style: subHeadline),
                  ),
                  pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(invoiceData['companyInfo']['addressGeneral'],
                  textAlign: pw.TextAlign.center,
                  style: subHeadline),
                  ),
                        pw.Divider(thickness: 0.1),
                  pw.Column(
                  children: List.generate((entries.length/ 2).ceil(), (index) {
                  final startIndex = index * 2;
                  final endIndex = startIndex + 2;

                  final rowEntries = entries.sublist(startIndex, endIndex.clamp(0, entries.length));

                  return pw.Row(
                  children: rowEntries.map<pw.Widget>((entry) {
                  return pw.Expanded(
                  child: pw.Padding(
                  padding: const pw.EdgeInsets.all(1.0),
                  child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                  pw.Text('${entry.key}: ', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold)),
                  pw.Text(entry.value,style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal)),
                  ],
                  ),
                  ),
                  );
                  }).toList(),
                  );
                  }),
                  ),
                        pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.1),
                        /*pw.Align(
                          alignment : pw.Alignment.centerLeft,
                          child: pw.Text('ITEMS', style: pw.TextStyle(fontSize: 7,fontWeight: pw.FontWeight.bold),),
                        ),*/
                        pw.Column(
                          children: [
                            for(var item in (invoiceData['items'] as List<Map<String,dynamic>>))
                              pw.Row(
                                crossAxisAlignment : pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(item['Item'].toString(),style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold),),
                                      pw.Text('${item['Qty']} x ${item['Price'].toStringAsFixed(2)}',
                                          style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal)),
                                    ],
                                  )),
                                  pw.Text(item['Amount'].toStringAsFixed(2),style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal)),
                                ],
                              )
                          ],
                        ),
                          pw.Divider(thickness: 0.1),
  /*                pw.TableHelper.fromTextArray(
                 border: const pw.TableBorder(
                  top: pw.BorderSide(
                  color: PdfColors.white,
                  width: .0,
                  ),
                  left: pw.BorderSide(
                  color: PdfColors.white,
                  width: .0,
                  ),
                  right: pw.BorderSide(
                  color: PdfColors.white,
                  width: .0,
                  ),
                  bottom: pw.BorderSide(
                  color: PdfColors.white,
                  width: .0,
                  ),
                  verticalInside: pw.BorderSide(
                  color: PdfColors.white,
                  width: .0,
                  )),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(
                  //borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                  color: PdfColors.white,
                  border: pw.Border(
                  left: pw.BorderSide(
                  color: PdfColors.white,
                  width: .1,
                  ),
                  right: pw.BorderSide(
                  color: PdfColors.white,
                  width: .1,
                  ),
                  bottom: pw.BorderSide(
                  color: PdfColors.grey,
                  width: .1,
                  ),
                  )),
                  headerHeight: 14,
                  cellHeight: 12,
                  cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  },
                  headerStyle: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 6,
                  ),
                  rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                  bottom: pw.BorderSide(
                  color: PdfColors.grey,
                  width: .1,
                  ),
                  ),
                  ),
                  headers: ['Item','Qty','Price','Amount'],
                  data: List<List<String>>.generate(invoiceData['items'].length, (row) {
                  final item = invoiceData['items'][row];
                  return [
                  item['Item'],
                  item['Qty'].toString(),
                  item['Price'].toStringAsFixed(2),
                  item['Amount'].toStringAsFixed(2),
                  ];
                  }),
                  ),*/
                        //pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Expanded(child: pw.Container()),
                            pw.Expanded(child: pw.Column(
                              children: [
                                for(var key in invoiceData['breakdown'].keys)
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(key, style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold),),
                                      pw.Text(invoiceData['breakdown'][key].toStringAsFixed(2),style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal))
                                    ],),
                              ]
                            ))
                          ]
                        ),
                        //pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(child: pw.Container()),
                            pw.Expanded(child: pw.Column(
                              children: [
                                pw.Divider(),
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold),),
                                    pw.Text(invoiceData['total'].toStringAsFixed(2),style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal))
                                  ],),
                              ]
                            ))
                          ]
                        ),
                        pw.Divider(thickness: 0.1),
                        pw.Align(
                          alignment : pw.Alignment.centerLeft,
                          child: pw.Text('SDC INFORMATION', style: pw.TextStyle(fontSize: 7,fontWeight: pw.FontWeight.bold),),
                        ),
                        for(var key in invoiceData['sdcInfo'].keys)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(key, style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold) ,),
                              pw.Text(invoiceData['sdcInfo'][key].toString(),style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.normal))
                            ],),
                        pw.SizedBox(height: 32,),
                        pw.Align(
                          alignment : pw.Alignment.center,
                          child: pw.Image(pw.MemoryImage(qrImageBytes!.buffer.asUint8List()),
                              width: 128, height: 128,fit: pw.BoxFit.cover),
                        ),
                        pw.SizedBox(height: 32),
                  ]
                  ); // Center
                })); // Page
            await Printing.layoutPdf(
                format: PdfPageFormat.a4,
                onLayout: (PdfPageFormat format) async => pdf.save());
            //await Printing.sharePdf(bytes: await pdf.save(), filename: 'my-document.pdf');
          }, icon: const Icon(Icons.print)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset('assets/images/slack.png', height: 32, width: 32,),
            Align(
              alignment: Alignment.center,
              child: Text(
                invoiceData['companyInfo']['companyName'],
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                invoiceData['companyInfo']['addressSpecific'],
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                invoiceData['companyInfo']['addressGeneral'],
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            MapDisplayWidget(data: invoiceData['invoiceInfo']),
            const Divider(),
            DataTable(
              dividerThickness: 0,
              headingRowHeight: 32,
              dataRowMinHeight: 24,
              dataRowMaxHeight: 24,
              horizontalMargin: 0,
              border: TableBorder(
              ),
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty'), numeric: true),
                DataColumn(label: Text('Price'), numeric: true),
                DataColumn(label: Text('Amount'), numeric: true),
              ],
              rows: (invoiceData['items'] as List).map((e) {
                final item = e as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(e['Item'])),
                  DataCell(Text(e['Qty'].toString())),
                  DataCell(Text(e['Price'].toString())),
                  DataCell(Text(e['Amount'].toString())),

                ]);
              }).toList(),),
            const Divider(),
            Column(
              children: [
                for(var item in (invoiceData['items'] as List<Map<String,dynamic>>))
                  Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['Item'].toString(),style: Theme.of(context).textTheme.labelMedium,),
                          Text('${item['Qty']} x ${item['Price']}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )),
                      Text(item['Amount'].toString()),
                    ],
                  )
              ],
            ),
            const Divider(),
            for(var key in invoiceData['breakdown'].keys)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(key, style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge,),
                  Text(invoiceData['breakdown'][key].toStringAsFixed(2))
                ],),
            const Divider(thickness: 2, color: Colors.black,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: Theme
                    .of(context)
                    .textTheme
                    .labelLarge,),
                Text(invoiceData['total'].toStringAsFixed(2))
              ],),
            const Divider(thickness: 2, color: Colors.black,),
            Text('SDC INFORMATION', style: Theme
                .of(context)
                .textTheme
                .titleMedium,),
            for(var key in invoiceData['sdcInfo'].keys)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(key, style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge,),
                  Text(invoiceData['sdcInfo'][key].toString())
                ],),
            const SizedBox(height: 32,),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 256,
                width: 256,
                child: PrettyQrView.data(
                  data: invoiceData['qrcode'],
                  decoration: const PrettyQrDecoration(

                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapDisplayWidget extends StatelessWidget {

  const MapDisplayWidget({super.key, required this.data});

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: (entries.length / 2).ceil(),
      itemBuilder: (context, index) {
        final startIndex = index * 2;
        final endIndex = startIndex + 2;

        final rowEntries = entries.sublist(
            startIndex, endIndex.clamp(0, entries.length));

        return Row(
          children: rowEntries.map((entry) {
            return Expanded(
              child: Row(
                children: [
                  Text('${entry.key}:', style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge,),
                  const SizedBox(width: 4,),
                  Text(entry.value, style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

