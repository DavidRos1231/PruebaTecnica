import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:test_operati_frontend/services/api_service.dart';

import 'models/capacidad_demanda.dart';

class CapacidadDemandaScreen extends StatefulWidget {
  @override
  _CapacidadDemandaScreenState createState() => _CapacidadDemandaScreenState();
}

class _CapacidadDemandaScreenState extends State<CapacidadDemandaScreen> {
  List<CapacidadDemanda> capacidadDemandaList = [];
  bool isLoading = false;
  bool isDownloading = false;
  String errorMessage = '';

  int currentPage = 0;
  int pageSize = 10;
  int totalElements = 0;
  int totalPages = 0;

  String filter = '';
  String sortBy = 'id';
  String sortDirection = 'asc';

  final TextEditingController filterController = TextEditingController();
  final NumberFormat numberFormat = NumberFormat('#,##0.000000');

  // ScrollController for horizontal scrolling synchronization
  final ScrollController _horizontalScrollController = ScrollController();

  // Responsive breakpoints
  bool get isMobile => MediaQuery.of(context).size.width < 768;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  double get horizontalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 32.0;
    return 160.0;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final response = await ApiService.getPaginatedData(
      page: currentPage,
      size: pageSize,
      sortBy: sortBy,
      direction: sortDirection,
      filter: filter.isEmpty ? 'none' : filter,
    );

    setState(() {
      isLoading = false;
      if (response.success && response.data != null) {
        capacidadDemandaList = response.data!.content;
        totalElements = response.data!.totalElements;
        totalPages = response.data!.totalPages;
        errorMessage = '';
      } else {
        errorMessage = response.message;
        capacidadDemandaList = [];
      }
    });
  }

  Future<void> downloadFile() async {
    setState(() {
      isDownloading = true;
      errorMessage = '';
    });

    final response = await ApiService.downloadAndSaveFile();

    setState(() {
      isDownloading = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await loadData();
    } else {
      setState(() {
        errorMessage = response.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void applyFilter() {
    setState(() {
      filter = filterController.text.trim();
      currentPage = 0;
    });
    loadData();
  }

  void clearFilter() {
    setState(() {
      filter = '';
      filterController.clear();
      currentPage = 0;
    });
    loadData();
  }

  void changePage(int newPage) {
    if (newPage >= 0 && newPage < totalPages) {
      setState(() {
        currentPage = newPage;
      });
      loadData();
    }
  }

  void changePageSize(int newSize) {
    setState(() {
      pageSize = newSize;
      currentPage = 0;
    });
    loadData();
  }

  void changeSorting(String column) {
    setState(() {
      if (sortBy == column) {
        sortDirection = sortDirection == 'asc' ? 'desc' : 'asc';
      } else {
        sortBy = column;
        sortDirection = 'asc';
      }
      currentPage = 0;
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isMobile
            ? Text('Capacidad Demanda', style: TextStyle(fontSize: 16))
            : Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: horizontalPadding - 30),
                child: Text('Gestor de Capacidad Demanda'),
              ),
        actions: [
          if (!isMobile) ...[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: _showInfoDialog,
              tooltip: 'Información',
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: isLoading ? null : loadData,
              tooltip: 'Actualizar datos',
            ),
            SizedBox(width: horizontalPadding),
          ] else ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'info':
                    _showInfoDialog();
                    break;
                  case 'refresh':
                    if (!isLoading) loadData();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Información'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Actualizar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterSection(),
          Expanded(
            child: Stack(
              children: [
                _buildDataSection(),
                if (totalPages > 1)
                  _buildPaginationSection()
                else
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          height: 64,
                          padding: EdgeInsets.all(16),
                          child: Text("No hay mas paginas"),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(color: Colors.grey[300]!)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, -1),
                              ),
                            ],
                          )))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cómo usar'),
          content: Text('Para ordenar por campo, presione el nombre del campo. '
              'Para filtrar por un campo, escriba en el campo de texto y presione enter. '
              'Para descargar el archivo, presione el botón de descarga.'),
          actions: [
            TextButton(
              child: Text('Entendido'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: !isMobile? EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding): EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total de registros: $totalElements',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (filter.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            'Filtrado por: "$filter"',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isDownloading ? null : downloadFile,
            icon: isDownloading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.download, color: Colors.white),
            label:
                Text(isDownloading ? 'Descargando...' : 'Descargar y procesar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total de registros: $totalElements',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (filter.isNotEmpty)
                Text(
                  'Filtrado por: "$filter"',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: isDownloading ? null : downloadFile,
          icon: isDownloading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.download, color: Colors.white),
          label:
              Text(isDownloading ? 'Descargando...' : 'Descargar y procesar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: !isMobile? EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding): EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: isMobile ? _buildMobileFilter() : _buildDesktopFilter(),
    );
  }

  Widget _buildMobileFilter() {
    return Column(
      children: [
        TextField(
          controller: filterController,
          decoration: InputDecoration(
            labelText: 'Filtrar por cualquier campo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            suffixIcon: filter.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: clearFilter,
                  )
                : null,
          ),
          onSubmitted: (_) => applyFilter(),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: applyFilter,
                child: Text('Aplicar filtro'),
              ),
            ),
            SizedBox(width: 12),
            DropdownButton<int>(
              value: pageSize,
              items: [2,5, 10, 20, 50].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size por página'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) changePageSize(value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: filterController,
            decoration: InputDecoration(
              labelText: 'Filtrar por cualquier campo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon: filter.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: clearFilter,
                    )
                  : null,
            ),
            onSubmitted: (_) => applyFilter(),
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
          onPressed: applyFilter,
          child: Text('Aplicar filtro'),
        ),
        SizedBox(width: 8),
        DropdownButton<int>(
          value: pageSize,
          items: [2,5, 10, 20, 50].map((size) {
            return DropdownMenuItem(
              value: size,
              child: Text('$size por página'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) changePageSize(value);
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding / 8, 0,
          horizontalPadding / 8, totalPages > 1 ? (isMobile ? 100 : 80) : 16),
      child: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Colors.grey[800],
                size: 50.0,
              ),
            )
          : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : capacidadDemandaList.isEmpty
                  ? _buildEmptyWidget()
                  : isMobile
                      ? _buildMobileDataList()
                      : _buildDataTable(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadData,
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron datos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Intente descargar datos o ajustar su filtro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDataList() {
    return ListView.builder(
      itemCount: capacidadDemandaList.length,
      itemBuilder: (context, index) {
        final item = capacidadDemandaList[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileDataRow('ID', item.id.toString()),
                _buildMobileDataRow('Zona de Potencia', item.zonaPotencia),
                _buildMobileDataRow('Participante', item.participante),
                _buildMobileDataRow('Subcuenta', item.subcuentaParticipante),
                _buildMobileDataRow('Capacidad Demanda',
                    numberFormat.format(item.capacidadDemanda)),
                _buildMobileDataRow('Req. Anual Potencia',
                    numberFormat.format(item.requisitoAnualPotencia)),
                _buildMobileDataRow('Req. Anual Pot. Eficiente',
                    numberFormat.format(item.requisitoAnualPotenciaEficiente)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: EdgeInsets.only(bottom: 56),
      padding:
          EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding / 8),
      child: Column(
        children: [
          // Sticky Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: _buildHeaderRow(),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                child: _buildDataRows(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final double columnWidth = isTablet ? 120.0 : 150.0;
    return Container(
      height: 56.0,
      child: Row(
        children: [
          _buildHeaderCell('ID', 'id', columnWidth),
          _buildHeaderCell('Zona Potencia', 'zonaPotencia', columnWidth),
          _buildHeaderCell('Participante', 'participante', columnWidth),
          _buildHeaderCell('Subcuenta', 'subcuentaParticipante', columnWidth),
          _buildHeaderCell(
              'Capacidad Demanda', 'capacidadDemanda', columnWidth),
          _buildHeaderCell(
              'Req. Anual Potencia', 'requisitoAnualPotencia', columnWidth),
          _buildHeaderCell('Req. Anual Pot. Eficiente',
              'requisitoAnualPotenciaEficiente', columnWidth),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, String field, double width) {
    return Container(
      width: width,
      height: 56.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: InkWell(
        onTap: () => changeSorting(field),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (sortBy == field)
              Icon(
                sortDirection == 'asc'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRows() {
    final double columnWidth = isTablet ? 120.0 : 150.0;
    return Column(
      children: capacidadDemandaList.map((item) {
        return Container(
          height: 48.0,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              _buildDataCell(item.id.toString(), columnWidth),
              _buildDataCell(item.zonaPotencia, columnWidth),
              _buildDataCell(item.participante, columnWidth),
              _buildDataCell(item.subcuentaParticipante, columnWidth),
              _buildDataCell(
                  numberFormat.format(item.capacidadDemanda), columnWidth),
              _buildDataCell(numberFormat.format(item.requisitoAnualPotencia),
                  columnWidth),
              _buildDataCell(
                  numberFormat.format(item.requisitoAnualPotenciaEficiente),
                  columnWidth),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      height: 48.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: isTablet ? 11 : 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPaginationSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isMobile ? 100 : 64,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: isMobile ? _buildMobilePagination() : _buildDesktopPagination(),
      ),
    );
  }

  Widget _buildMobilePagination() {
    return Column(
      children: [
        Text(
          'Página ${currentPage + 1} de $totalPages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed:
                  currentPage > 0 ? () => changePage(currentPage - 1) : null,
              icon: Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
            ),
            Text('${currentPage + 1}'),
            IconButton(
              onPressed: currentPage < totalPages - 1
                  ? () => changePage(currentPage + 1)
                  : null,
              icon: Icon(Icons.chevron_right),
              tooltip: 'Página siguiente',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Página ${currentPage + 1} de $totalPages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              onPressed:
                  currentPage > 0 ? () => changePage(currentPage - 1) : null,
              icon: Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
            ),
            ...List.generate(
              totalPages > 5 ? 5 : totalPages,
              (index) {
                int pageNumber;
                if (totalPages <= 5) {
                  pageNumber = index;
                } else {
                  if (currentPage < 3) {
                    pageNumber = index;
                  } else if (currentPage >= totalPages - 3) {
                    pageNumber = totalPages - 5 + index;
                  } else {
                    pageNumber = currentPage - 2 + index;
                  }
                }

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: () => changePage(pageNumber),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          pageNumber == currentPage ? Colors.grey[800] : null,
                      foregroundColor:
                          pageNumber == currentPage ? Colors.white : null,
                    ),
                    child: Text('${pageNumber + 1}'),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: currentPage < totalPages - 1
                  ? () => changePage(currentPage + 1)
                  : null,
              icon: Icon(Icons.chevron_right),
              tooltip: 'Página siguiente',
            )
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    filterController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}
