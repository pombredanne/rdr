(* 
#directory "/home/m4b/projects/rdr/_build/lib/utils";;
#load "Binary.cmo";;
*)
open Binary

(* 
[@printer fun fmt -> fprintf fmt "0x%x"];
 *)
       
type dos_header =
  {
    signature: int [@size 2]; (* 5a4d *)
    pe_pointer: int [@size 4];  (* at offset 0x3c *)
  }

let pp_dos_header ppf dos =
  Format.fprintf ppf "@[DOS@ %x@ PE -> 0x%x@]"
    dos.signature
    dos.pe_pointer

let kDOS_MAGIC = 0x5a4d
let kDOS_CIGAM = 0x4d5a
let kPE_POINTER_OFFSET = 0x3c

(* COFF Header *)
type coff_header =
  {
    signature: int [@size 4, be]; (* 0x50450000 *)
    machine: int [@size 2];
    number_of_sections: int [@size 2];
    time_date_stamp: int [@size 4];
    pointer_to_symbol_table: int [@size 4];
    number_of_symbol_table: int [@size 4];
    size_of_optional_header: int [@size 2];
    characteristics: int [@size 2];
  }

let sizeof_coff_header = 24     (* bytes *)
let kCOFF_MAGIC = 0x50450000

let pp_coff_header ppf coff =
  Format.fprintf ppf
    "@[<v 2>@[<h>COFF@ 0x%x@]@ Machine: 0x%x@ NumberOfSections: %d@ TimeDateStamp: %d@ PointerToSymbolTable: 0x%x@ NumberOfSymbolTable: %d@ SizeOfOptionalHeader: 0x%x@ Characteristics: 0x%x@]"
    coff.signature
    coff.machine
    coff.number_of_sections
    coff.time_date_stamp
    coff.pointer_to_symbol_table
    coff.number_of_symbol_table
    coff.size_of_optional_header
    coff.characteristics

(* standard COFF fields *)
type standard_fields =
  {
    magic: int [@size 2];
    major_linker_version: int [@size 1];
    minor_linker_version: int [@size 1];
    size_of_code: int [@size 4];
    size_of_initialized_data: int [@size 4];
    size_of_uninitialized_data: int [@size 4];
    address_of_entry_point: int [@size 4];
    base_of_code: int [@size 4];
    base_of_data: int [@size 4]; (* absent in 64-bit PE32+ *)
  }

let sizeof_standard_fields = (3 * 8) + 4

let pp_standard_fields ppf standard =
  Format.fprintf ppf
    "@[<v 2>@[<h>Standard@ 0x%x@]@ MajorLinkerVersion: %d@ MinorLinkerVersion: %d@ SizeOfCode: 0x%x@ SizeOfInitializedData: 0x%x@ SizeOfUninitializedData: 0x%x@ AddressOfEntryPoint: 0x%x@ BaseOfCode: 0x%x@ BaseOfData: 0x%x@]"
    standard.magic
    standard.major_linker_version
    standard.minor_linker_version
    standard.size_of_code
    standard.size_of_initialized_data
    standard.size_of_uninitialized_data
    standard.address_of_entry_point
    standard.base_of_code
    standard.base_of_data

(* windows specific fields *)
type windows_fields =
  {
    image_base: int [@size 4];  (* 8 in 64-bit *)
    section_alignment: int [@size 4];
    file_alignment: int [@size 4];
    major_operating_system_version: int [@size 2];
    minor_operating_system_version: int [@size 2];
    major_image_version: int [@size 2];
    minor_image_version: int [@size 2];
    major_subsystem_version: int [@size 2];
    minor_subsystem_version: int [@size 2];
    win32_version_value: int [@size 4];
    size_of_image: int [@size 4];
    size_of_headers: int [@size 4];
    check_sum: int [@size 4];
    subsystem: int [@size 2];
    dll_characteristics: int [@size 2];
    size_of_stack_reserve: int [@size 4]; (* 8 64-bit *)
    size_of_stack_commit: int [@size 4];  (* 8 *)
    size_of_heap_reserve: int [@size 4];  (* 8 *)
    size_of_heap_commit: int [@size 4];   (* 8 *)
    loader_flags: int [@size 4];
    number_of_rva_and_sizes: int [@size 4];
  }

let sizeof_windows_fields = (8 * 8) + 4

let pp_windows_fields ppf windows =
  Format.fprintf ppf
    "@[<v 2>@[Windows@]@ ImageBase: 0x%x@ SectionAlignment: 0x%x@ FileAlignment: 0x%x@ MajorOperatingSystemVersion: %d@ MinorOperatingSystemVersion: %d@ MajorImageVersion: %d@ MinorImageVersion: %d@ MajorSubsystemVersion: %d@ MinorSubsystemVersion: %d@ Win32VersionValue: %d@ SizeOfImage: 0x%x@ SizeOfHeaders: 0x%x@ CheckSum: 0x%x@ Subsystem: 0x%x@ DLL_Characteristics: 0x%x@ SizeOfStackReserve: 0x%x@ SizeOfStackCommit: 0x%x@ SizeOfHeapReserve: 0x%x@ SizeOfHeapCommit: 0x%x@ LoaderFlags: 0x%x@ NumberOfRvaAndSizes: %d@]"
    windows.image_base
    windows.section_alignment
    windows.file_alignment
    windows.major_operating_system_version
    windows.minor_operating_system_version
    windows.major_image_version
    windows.minor_image_version
    windows.major_subsystem_version
    windows.minor_subsystem_version
    windows.win32_version_value
    windows.size_of_image
    windows.size_of_headers
    windows.check_sum
    windows.subsystem
    windows.dll_characteristics
    windows.size_of_stack_reserve
    windows.size_of_stack_commit
    windows.size_of_heap_reserve
    windows.size_of_heap_commit
    windows.loader_flags
    windows.number_of_rva_and_sizes

(* TODO: module DataDirectories *)
(* these are variable width and only exist if number_of_rva_and_sizes allows them *)
type data_directories =
  {
    export_table: int [@size 4];
    size_of_export_table: int [@size 4];
    import_table: int [@size 4];
    size_of_import_table: int [@size 4];
    resource_table: int [@size 4];
    size_of_resource_table: int [@size 4];
    exception_table: int [@size 4];
    size_of_exception_table: int [@size 4];
    certificate_table: int [@size 4];
    size_of_certificate_table: int [@size 4];
    base_relocation_table: int [@size 4];
    size_of_base_relocation_table: int [@size 4];
    debug: int [@size 4];
    size_of_debug: int [@size 4];
    architecture: int [@size 4];
    size_of_architecture: int [@size 4];    
    global_ptr: int [@size 4];
    size_of_global_ptr: int [@size 4];
    tls_table: int [@size 4];
    size_of_tls_table: int [@size 4];
    load_config_table: int [@size 4];
    size_of_load_config_table: int [@size 4];
    bound_import: int [@size 4];
    size_of_bound_import: int [@size 4];
    import_address_table: int [@size 4];
    size_of_import_address_table: int [@size 4];
    delay_import_descriptor: int [@size 4];
    size_of_delay_import_descriptor: int [@size 4];
    clr_runtime_header: int [@size 4];
    size_of_clr_runtime_header: int [@size 4];
    reserved: int [@size 8, padding];
  }

let sizeof_data_directories = 15 * 8

let pp_data_directories ppf dd =
  Format.fprintf ppf
    "@[<v 2>@[Data Directories@]@ ExportTable: 0x%x@ SizeOfExportTable: 0x%x@ ImportTable: 0x%x@ SizeOfImportTable: 0x%x@ ResourceTable: 0x%x@ SizeOfResourceTable: 0x%x@ ExceptionTable: 0x%x@ SizeOfExceptionTable: 0x%x@ CertificateTable: 0x%x@ SizeOfCertificateTable: 0x%x@ BaseRelocationTable: 0x%x@ SizeOfBaseRelocationTable: 0x%x@ Debug: 0x%x@ SizeOfDebugTable: 0x%x@ Architecture: 0x%x@ SizeOfArchitecture: 0x%x@ GlobalPtr: 0x%x@ SizeOfGlobalPtr: 0x%x@ TlsTable: 0x%x@ SizeOfTlsTable: 0x%x@ LoadConfigTable: 0x%x@ SizeOfLoadConfigTable: 0x%x@ BoundImport: 0x%x@ SizeOfBoundImport: 0x%x@ ImportAddressTable: 0x%x@ SizeOfImportAddressTable: 0x%x@ DelayImportDescriptor: 0x%x@ SizeOfDelayImportDescriptor: 0x%x@ ClrRuntimeHeader: 0x%x@ SizeOfRuntimeHeader: 0x%x@]"
    dd.export_table
    dd.size_of_export_table
    dd.import_table
    dd.size_of_import_table
    dd.resource_table
    dd.size_of_resource_table
    dd.exception_table
    dd.size_of_exception_table
    dd.certificate_table
    dd.size_of_certificate_table
    dd.base_relocation_table
    dd.size_of_base_relocation_table
    dd.debug
    dd.size_of_debug
    dd.architecture
    dd.size_of_architecture
    dd.global_ptr
    dd.size_of_global_ptr
    dd.tls_table
    dd.size_of_tls_table
    dd.load_config_table
    dd.size_of_load_config_table
    dd.bound_import
    dd.size_of_bound_import
    dd.import_address_table
    dd.size_of_import_address_table
    dd.delay_import_descriptor
    dd.size_of_delay_import_descriptor
    dd.clr_runtime_header
    dd.size_of_clr_runtime_header

type section_table = {
    name: string [@size 8];
    virtual_size: int [@size 4];
    virtual_address: int [@size 4];
    size_of_raw_data: int [@size 4];
    pointer_to_raw_data: int [@size 4];
    pointer_to_relocations: int [@size 4];
    pointer_to_linenumbers: int [@size 4];
    number_of_relocations: int [@size 2];
    number_of_linenumbers: int [@size 2];
    characteristics: int [@size 4];
  }

let sizeof_section_table = 8 * 5

let pp_section_table ppf section =
  Format.fprintf ppf
    "@[<v 2>%s@ VirtualSize: 0x%x@ VirtualAddress: 0x%x@ SizeOofRawData: 0x%x@ PointerToRawData: 0x%x@ PointerToRelocations: 0x%x@ PointerToLinenumbers: 0x%x@ NumberOfRelocations: 0x%x@ NumberOfLinenumbers: 0x%x@ Characteristics: 0x%x@]"
    section.name
    section.virtual_size
    section.virtual_address
    section.size_of_raw_data
    section.pointer_to_raw_data
    section.pointer_to_relocations
    section.pointer_to_linenumbers
    section.number_of_relocations
    section.number_of_linenumbers
    section.characteristics

type optional_header =
  {
    standard_fields: standard_fields;
    windows_fields: windows_fields;
    data_directories: data_directories;
  }

let pp_optional_header ppf header =
  Format.fprintf ppf "@ ";
  pp_standard_fields ppf header.standard_fields;
  Format.fprintf ppf "@ ";
  pp_windows_fields ppf header.windows_fields;
  Format.fprintf ppf "@ ";
  pp_data_directories ppf header.data_directories


type t = {
    dos_header: dos_header;
    coff_header: coff_header;
    optional_header: optional_header option;
    section_tables: section_table list;
  }

let pp ppf t =
  Format.fprintf ppf "@[<v 2>@ ";
  pp_dos_header ppf t.dos_header;
  Format.fprintf ppf "@ ";
  pp_coff_header ppf t.coff_header;
  match t.optional_header with
  | Some header ->
    pp_optional_header ppf header;
  | None ->
    Format.fprintf ppf "@ **No Optional Headers**";
  Format.fprintf ppf "@ @[<v 2>Section Tables@ ";
  RdrPrinter.pp_seq ppf pp_section_table t.section_tables;
  Format.fprintf ppf "@]@]"

let show t =
  pp Format.str_formatter t;
  Format.flush_str_formatter()

let print t =
  pp Format.std_formatter t;
  Format.print_newline()

let get_dos_header binary offset :dos_header =
  let signature,o = Binary.u16o binary offset in
  let pe_pointer = Binary.u32 binary (offset+kPE_POINTER_OFFSET) in
  {signature;pe_pointer;}

let get_coff_header binary offset :coff_header =
  let signature,o = Binary.u32o binary offset in
  let machine,o = Binary.u16o binary o in
  let number_of_sections,o = Binary.u16o binary o in
  let time_date_stamp,o = Binary.u32o binary o in
  let pointer_to_symbol_table,o = Binary.u32o binary o in
  let number_of_symbol_table,o = Binary.u32o binary o in
  let size_of_optional_header,o = Binary.u16o binary o in
  let characteristics = Binary.u16 binary o in
  {signature;machine;number_of_sections;time_date_stamp;pointer_to_symbol_table;number_of_symbol_table;size_of_optional_header;characteristics;}

let get_standard_fields binary offset :standard_fields =
  let magic,o = Binary.u16o binary offset in
  let major_linker_version,o = Binary.u8o binary o in
  let minor_linker_version,o = Binary.u8o binary o in
  let size_of_code,o = Binary.u32o binary o in
  let size_of_initialized_data,o = Binary.u32o binary o in
  let size_of_uninitialized_data,o = Binary.u32o binary o in
  let address_of_entry_point,o = Binary.u32o binary o in
  let base_of_code,o = Binary.u32o binary o in
  let base_of_data = Binary.u32 binary o in
  {magic;major_linker_version;minor_linker_version;size_of_code;size_of_initialized_data;size_of_uninitialized_data;address_of_entry_point;base_of_code;base_of_data;}

let get_windows_fields binary offset :windows_fields =
  let image_base,o = Binary.u32o binary offset in
  let section_alignment,o = Binary.u32o binary o in
  let file_alignment,o = Binary.u32o binary o in
  let major_operating_system_version,o = Binary.u16o binary o in
  let minor_operating_system_version,o = Binary.u16o binary o in
  let major_image_version,o = Binary.u16o binary o in
  let minor_image_version,o = Binary.u16o binary o in
  let major_subsystem_version,o = Binary.u16o binary o in
  let minor_subsystem_version,o = Binary.u16o binary o in
  let win32_version_value,o = Binary.u32o binary o in
  let size_of_image,o = Binary.u32o binary o in
  let size_of_headers,o = Binary.u32o binary o in
  let check_sum,o = Binary.u32o binary o in
  let subsystem,o = Binary.u16o binary o in
  let dll_characteristics,o = Binary.u16o binary o in
  let size_of_stack_reserve,o = Binary.u32o binary o in
  let size_of_stack_commit,o = Binary.u32o binary o in
  let size_of_heap_reserve,o = Binary.u32o binary o in
  let size_of_heap_commit,o = Binary.u32o binary o in
  let loader_flags,o = Binary.u32o binary o in
  let number_of_rva_and_sizes = Binary.u32 binary o in
  {image_base;section_alignment;file_alignment;major_operating_system_version;minor_operating_system_version;major_image_version;minor_image_version;major_subsystem_version;minor_subsystem_version;win32_version_value;size_of_image;size_of_headers;check_sum;subsystem;dll_characteristics;size_of_stack_reserve;size_of_stack_commit;size_of_heap_reserve;size_of_heap_commit;loader_flags;number_of_rva_and_sizes;}

let get_data_directories binary offset :data_directories =
  let export_table,o = Binary.u32o binary offset in
  let size_of_export_table,o = Binary.u32o binary o in
  let import_table,o = Binary.u32o binary o in
  let size_of_import_table,o = Binary.u32o binary o in
  let resource_table,o = Binary.u32o binary o in
  let size_of_resource_table,o = Binary.u32o binary o in
  let exception_table,o = Binary.u32o binary o in
  let size_of_exception_table,o = Binary.u32o binary o in
  let certificate_table,o = Binary.u32o binary o in
  let size_of_certificate_table,o = Binary.u32o binary o in
  let base_relocation_table,o = Binary.u32o binary o in
  let size_of_base_relocation_table,o = Binary.u32o binary o in
  let debug,o = Binary.u32o binary o in
  let size_of_debug,o = Binary.u32o binary o in
  let architecture,o = Binary.u32o binary o in
  let size_of_architecture,o = Binary.u32o binary o in
  let global_ptr,o = Binary.u32o binary o in
  let size_of_global_ptr,o = Binary.u32o binary o in
  let tls_table,o = Binary.u32o binary o in
  let size_of_tls_table,o = Binary.u32o binary o in
  let load_config_table,o = Binary.u32o binary o in
  let size_of_load_config_table,o = Binary.u32o binary o in
  let bound_import,o = Binary.u32o binary o in
  let size_of_bound_import,o = Binary.u32o binary o in
  let import_address_table,o = Binary.u32o binary o in
  let size_of_import_address_table,o = Binary.u32o binary o in
  let delay_import_descriptor,o = Binary.u32o binary o in
  let size_of_delay_import_descriptor,o = Binary.u32o binary o in
  let clr_runtime_header,o = Binary.u32o binary o in
  let size_of_clr_runtime_header,o = Binary.u32o binary o in
  let reserved = Binary.u64 binary o in
  {export_table;size_of_export_table;import_table;size_of_import_table;resource_table;size_of_resource_table;exception_table;size_of_exception_table;certificate_table;size_of_certificate_table;base_relocation_table;size_of_base_relocation_table;debug;size_of_debug;architecture;size_of_architecture;global_ptr;size_of_global_ptr;tls_table;size_of_tls_table;load_config_table;size_of_load_config_table;bound_import;size_of_bound_import;import_address_table;size_of_import_address_table;delay_import_descriptor;size_of_delay_import_descriptor;clr_runtime_header;size_of_clr_runtime_header;reserved;}

let get_section_table binary offset :section_table =
  let name,o = Binary.stringo binary offset ~num_bytes:8 in
  let virtual_size,o = Binary.u32o binary o in
  let virtual_address,o = Binary.u32o binary o in
  let size_of_raw_data,o = Binary.u32o binary o in
  let pointer_to_raw_data,o = Binary.u32o binary o in
  let pointer_to_relocations,o = Binary.u32o binary o in
  let pointer_to_linenumbers,o = Binary.u32o binary o in
  let number_of_relocations,o = Binary.u16o binary o in
  let number_of_linenumbers,o = Binary.u16o binary o in
  let characteristics = Binary.u32 binary o in
  {name;virtual_size;virtual_address;size_of_raw_data;pointer_to_raw_data;pointer_to_relocations;pointer_to_linenumbers;number_of_relocations;number_of_linenumbers;characteristics;}

let get_section_tables binary offset nsections =
  let rec loop acc count =
    if (count >= nsections) then
      List.rev acc
    else
      let o = offset + (count * sizeof_section_table) in
      let st = get_section_table binary o in
      loop (st::acc) (count+1)
  in loop [] 0

let get_header binary =
  let dos_header = get_dos_header binary 0 in
  let coff_header_offset = dos_header.pe_pointer in
  let coff_header = get_coff_header binary coff_header_offset in
  let section_tables_offset =
    coff_header_offset + sizeof_coff_header
    + coff_header.size_of_optional_header
  in
  let section_tables =
    get_section_tables binary section_tables_offset coff_header.number_of_sections in
  let optional_offset = sizeof_coff_header + coff_header_offset in
  let optional_header =
    if (coff_header.size_of_optional_header > 0) then
      let standard_fields = get_standard_fields binary optional_offset in
      let wf_offset = optional_offset + sizeof_standard_fields in
      let windows_fields = get_windows_fields binary wf_offset in
      let dd_offset = wf_offset + sizeof_windows_fields in
      let data_directories = get_data_directories binary dd_offset in
      Some {standard_fields; windows_fields; data_directories;}
    else
      None
  in
  {dos_header; coff_header;
   optional_header; section_tables}

let rec get_section name sections =
  match sections with
  | [] -> raise Not_found
  | section::sections ->
     if (section.name = name) then
       section
     else
       get_section name sections

(* this won't work, requires a constructed header
   but we don't know which header to construct yet *)
let is_32 header =
  match header.optional_header with
  | Some header ->
     header.standard_fields.magic = 0x10B
  | None -> false

let is_64 header =
  match header.optional_header with
  | Some header ->
     header.standard_fields.magic = 0x20B
  | None -> false

let csrss_header = get_header @@ list_to_bytes [0x4d; 0x5a; 0x90; 0x00; 0x03; 0x00; 0x00; 0x00; 0x04; 0x00; 0x00; 0x00; 0xff; 0xff; 0x00; 0x00;
0xb8; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0xd0; 0x00; 0x00; 0x00;
0x0e; 0x1f; 0xba; 0x0e; 0x00; 0xb4; 0x09; 0xcd; 0x21; 0xb8; 0x01; 0x4c; 0xcd; 0x21; 0x54; 0x68;
0x69; 0x73; 0x20; 0x70; 0x72; 0x6f; 0x67; 0x72; 0x61; 0x6d; 0x20; 0x63; 0x61; 0x6e; 0x6e; 0x6f;
0x74; 0x20; 0x62; 0x65; 0x20; 0x72; 0x75; 0x6e; 0x20; 0x69; 0x6e; 0x20; 0x44; 0x4f; 0x53; 0x20;
0x6d; 0x6f; 0x64; 0x65; 0x2e; 0x0d; 0x0d; 0x0a; 0x24; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0xaa; 0x4a; 0xc3; 0xeb; 0xee; 0x2b; 0xad; 0xb8; 0xee; 0x2b; 0xad; 0xb8; 0xee; 0x2b; 0xad; 0xb8;
0xee; 0x2b; 0xac; 0xb8; 0xfe; 0x2b; 0xad; 0xb8; 0x33; 0xd4; 0x66; 0xb8; 0xeb; 0x2b; 0xad; 0xb8;
0x33; 0xd4; 0x63; 0xb8; 0xea; 0x2b; 0xad; 0xb8; 0x33; 0xd4; 0x7a; 0xb8; 0xed; 0x2b; 0xad; 0xb8;
0x33; 0xd4; 0x64; 0xb8; 0xef; 0x2b; 0xad; 0xb8; 0x33; 0xd4; 0x61; 0xb8; 0xef; 0x2b; 0xad; 0xb8;
0x52; 0x69; 0x63; 0x68; 0xee; 0x2b; 0xad; 0xb8; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x50; 0x45; 0x00; 0x00; 0x4c; 0x01; 0x05; 0x00; 0xd9; 0x8f; 0x15; 0x52; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0xe0; 0x00; 0x02; 0x01; 0x0b; 0x01; 0x0b; 0x00; 0x00; 0x08; 0x00; 0x00;
0x00; 0x10; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x10; 0x11; 0x00; 0x00; 0x00; 0x10; 0x00; 0x00;
0x00; 0x20; 0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x10; 0x00; 0x00; 0x00; 0x02; 0x00; 0x00;
0x06; 0x00; 0x03; 0x00; 0x06; 0x00; 0x03; 0x00; 0x06; 0x00; 0x03; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x60; 0x00; 0x00; 0x00; 0x04; 0x00; 0x00; 0xe4; 0xab; 0x00; 0x00; 0x01; 0x00; 0x40; 0x05;
0x00; 0x00; 0x04; 0x00; 0x00; 0x30; 0x00; 0x00; 0x00; 0x00; 0x10; 0x00; 0x00; 0x10; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x10; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x3c; 0x30; 0x00; 0x00; 0x3c; 0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x00; 0x08; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x1a; 0x00; 0x00; 0xb8; 0x22; 0x00; 0x00;
0x00; 0x50; 0x00; 0x00; 0x38; 0x00; 0x00; 0x00; 0x10; 0x10; 0x00; 0x00; 0x38; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x68; 0x10; 0x00; 0x00; 0x5c; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x30; 0x00; 0x00; 0x3c; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x2e; 0x74; 0x65; 0x78; 0x74; 0x00; 0x00; 0x00;
0x24; 0x06; 0x00; 0x00; 0x00; 0x10; 0x00; 0x00; 0x00; 0x08; 0x00; 0x00; 0x00; 0x04; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x20; 0x00; 0x00; 0x60;
0x2e; 0x64; 0x61; 0x74; 0x61; 0x00; 0x00; 0x00; 0x3c; 0x03; 0x00; 0x00; 0x00; 0x20; 0x00; 0x00;
0x00; 0x02; 0x00; 0x00; 0x00; 0x0c; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0xc0; 0x2e; 0x69; 0x64; 0x61; 0x74; 0x61; 0x00; 0x00;
0xf8; 0x01; 0x00; 0x00; 0x00; 0x30; 0x00; 0x00; 0x00; 0x02; 0x00; 0x00; 0x00; 0x0e; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x40;
0x2e; 0x72; 0x73; 0x72; 0x63; 0x00; 0x00; 0x00; 0x00; 0x08; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00;
0x00; 0x08; 0x00; 0x00; 0x00; 0x10; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x42; 0x2e; 0x72; 0x65; 0x6c; 0x6f; 0x63; 0x00; 0x00;
0x86; 0x01; 0x00; 0x00; 0x00; 0x50; 0x00; 0x00; 0x00; 0x02; 0x00; 0x00; 0x00; 0x18; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x40; 0x00; 0x00; 0x42;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;
0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00;]

let to_hex hex = Printf.printf "0x%x\n" hex
