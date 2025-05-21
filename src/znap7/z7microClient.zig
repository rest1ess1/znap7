const isoConstants = @import("./isoConstants.zig");
const longword = isoConstants.longword;
const word = isoConstants.word;
const deltaSecs: u64 = 441763200; //Seconds between unixEpoch and Siemenes base

const errCliMask: longword = 0xFFF00000;
const errCliBase: longword = 0x000FFFFF;

const errCliInvalidParams: longword = 0x00200000;
const errCliJobPending: longword = 0x00300000;
const errCliTooManyItems: longword = 0x00400000;
const errCliInvalidWordLen: longword = 0x00500000;
const errCliPartialDataWritten: longword = 0x00600000;
const errCliSizeOverPDU: longword = 0x00700000;
const errCliInvalidPlcAnswer: longword = 0x00800000;
const errCliAddressOutOfRange: longword = 0x00900000;
const errCliInvalidTransportSize: longword = 0x00A00000;
const errCliWriteDataSizeMismatch: longword = 0x00B00000;
const errCliItemNotAvailable: longword = 0x00C00000;
const errCliInvalidValue: longword = 0x00D00000;
const errCliCannotStartPLC: longword = 0x00E00000;
const errCliAlreadyRun: longword = 0x00F00000;
const errCliCannotStopPLC: longword = 0x01000000;
const errCliCannotCopyRamToRom: longword = 0x01100000;
const errCliCannotCompress: longword = 0x01200000;
const errCliAlreadyStop: longword = 0x01300000;
const errCliFunNotAvailable: longword = 0x01400000;
const errCliUploadSequenceFailed: longword = 0x01500000;
const errCliInvalidDataSizeRecvd: longword = 0x01600000;
const errCliInvalidBlockType: longword = 0x01700000;
const errCliInvalidBlockNumber: longword = 0x01800000;
const errCliInvalidBlockSize: longword = 0x01900000;
const errCliDownloadSequenceFailed: longword = 0x01A00000;
const errCliInsertRefused: longword = 0x01B00000;
const errCliDeleteRefused: longword = 0x01C00000;
const errCliNeedPassword: longword = 0x01D00000;
const errCliInvalidPassword: longword = 0x01E00000;
const errCliNoPasswordToSetOrClear: longword = 0x01F00000;
const errCliJobTimeout: longword = 0x02000000;
const errCliPartialDataRead: longword = 0x02100000;
const errCliBufferTooSmall: longword = 0x02200000;
const errCliFunctionRefused: longword = 0x02300000;
const errCliDestroying: longword = 0x02400000;
const errCliInvalidParamNumber: longword = 0x02500000;
const errCliCannotChangeParam: longword = 0x02600000;

fn S7DataItem(comptime T: type) type {
    return packed struct {
        Area: i32,
        WordLen: i32,
        Result: i32,
        DBNumber: i32,
        Start: i32,
        Amount: i32,
        Data: *T,
    };
}

const S7BlocksList = packed struct {
    OBCount: i32,
    FBCount: i32,
    FCCount: i32,
    SFBCount: i32,
    SFCCount: i32,
    DBCount: i32,
    SDBCount: i32,
};

const S7BlockInfo = packed struct {
    BlkType: i32,
    BlkNumber: i32,
    BlkLang: i32,
    BlkFlags: i32,
    BlkMC7Size: i32,
    LoadSize: i32,
    LocalData: i32,
    SBBLength: i32,
    CheckSum: i32,
    Version: i32,
    CodeDate: u8[11],
    IntfDate: u8[11],
    Author: u8[9],
    Family: u8[9],
    Header: u8[9],
};

const S7BlocksOfType = word[0x2000];

const S7OrderCode = packed struct {
    Code: u8[21],
    V1: u8,
    V2: u8,
    V3: u8,
};

const S7CpuInfo = packed struct {
    MaxPduLength: i32,
    MaxConnections: i32,
    MaxMipRate: i32,
    MaxBusRate: i32,
};

// See §33.1 of "System Software for S7-300/400 System and Standard Functions"
// and see SFC51 description too
const SZL_HEADER = packed struct {
    LENTHDR: word,
    N_DR: word,
};

const S7SZL = packed struct {
    Header: SZL_HEADER,
    Data: u8[0x4000 - 4],
};

// SZL List of available SZL IDs : same as SZL but List items are big-endian adjusted
const S7SZLList = packed struct {
    Header: SZL_HEADER,
    List: word[0x2000 - 2],
};

// See §33.19 of "System Software for S7-300/400 System and Standard Functions"
const S7Protection = packed struct {
    sch_schal: word,
    sch_par: word,
    sch_rel: word,
    bart_sch: word,
    anl_sch: word,
};

const S7Op = enum(u8) {
    None = 0,
    ReadArea = 1,
    WriteArea = 2,
    ReadMultiVars = 3,
    WriteMultiVars = 4,
    DBGet = 5,
    Upload = 6,
    Download = 7,
    Delete = 8,
    ListBlocks = 9,
    AgBlockInfo = 10,
    ListBlocksOfType = 11,
    ReadSzlList = 12,
    ReadSZL = 13,
    GetDateTime = 14,
    SetDateTime = 15,
    GetOrderCode = 16,
    GetCpuInfo = 17,
    GetCpInfo = 18,
    GetPlcStatus = 19,
    PlcHotStart = 20,
    PlcColdStart = 21,
    CopyRamToRom = 22,
    Compress = 23,
    PlcStop = 24,
    GetProtection = 25,
    SetPassword = 26,
    ClearPassword = 27,
    DBFill = 28,
};

const pc_iso_SendTimeout: i32 = 6;
const pc_iso_RecvTimeout: i32 = 7;
const pc_iso_ConnTimeout: i32 = 8;
const pc_iso_SrcRef: i32 = 1;
const pc_iso_DstRef: i32 = 2;
const pc_iso_SrcTSAP: i32 = 3;
const pc_iso_DstTSAP: i32 = 4;
const pc_iso_IsoPduSize: i32 = 5;
