const byte = u8;
const word = u16;
const smallInt = i16;
const longWord = u32;
const longInt = i32;
const S7Object = usize;

const noError = 0;
const errIsoMask: longWord = 0x000F0000;
const errIsoBase: longWord = 0x0000FFFF;

const errIsoConnect: longWord = 0x00010000; // Connection error
const errIsoDisconnect: longWord = 0x00020000; // Disconnect error
const errIsoInvalidPDU: longWord = 0x00030000; // Bad format
const errIsoInvalidDataSize: longWord = 0x00040000; // Bad Datasize passed to send/recv : buffer is invalid
const errIsoNullPointer: longWord = 0x00050000; // Null passed as pointer
const errIsoShortPacket: longWord = 0x00060000; // A short packet received
const errIsoTooManyFragments: longWord = 0x00070000; // Too many packets without EoT flag
const errIsoPduOverflow: longWord = 0x00080000; // The sum of fragments data exceded maximum packet size
const errIsoSendPacket: longWord = 0x00090000; // An error occurred during send
const errIsoRecvPacket: longWord = 0x000A0000; // An error occurred during recv
const errIsoInvalidParams: longWord = 0x000B0000; // Invalid TSAP params
const errIsoResvd_1: longWord = 0x000C0000; // Unassigned
const errIsoResvd_2: longWord = 0x000D0000; // Unassigned
const errIsoResvd_3: longWord = 0x000E0000; // Unassigned
const errIsoResvd_4: longWord = 0x000F0000; // Unassigned

const ISO_OPT_TCP_NODELAY: longWord = 0x00000001; // Disable Nagle algorithm
const ISO_OPT_INSIDE_MTU: longWord = 0x00000002; // Max packet size < MTU ethernet card
const TTPKT = struct {
    Version: u8 = 3,
    Reserved: u8 = 0,
    HI_Lenght: u8,
    LO_Lenght: u8,
};

const TCOPT_Params = struct {
    PduSizeCode: u8,
    PduSizeLen: u8,
    PduSizeVal: u8,
    TSAP: u8[245],
};

// PDU Type constants - ISO 8073, not all are mentioned in RFC 1006
// For our purposes we use only those labeled with **
// These constants contains 4 low bit order 0 (credit nibble)
//
//     $10 ED : Expedited Data
//     $20 EA : Expedited Data Ack
//     $40 UD : CLTP UD
//     $50 RJ : Reject
//     $70 AK : Ack data
// **  $80 DR : Disconnect request (note : S7 doesn't use it)
// **  $C0 DC : Disconnect confirm (note : S7 doesn't use it)
// **  $D0 CC : Connection confirm
// **  $E0 CR : Connection request
// **  $F0 DT : Data

// COTP Header for CONNECTION REQUEST/CONFIRM - DISCONNECT REQUEST/CONFIRM
const TCOPT_CO = struct {
    HLength: u8 = 6, // Header length : initialized to 6 (length without params - 1)
    // descending classes that add values in params field must update it.
    PDUType: u8, // 0xE0 Connection request
    // 0xD0 Connection confirm
    // 0x80 Disconnect request
    // 0xDC Disconnect confirm
    DstRef: u8 = 0x0000, // Destination reference : Always 0x0000
    SrcRef: u8 = 0x0000, // Source reference : Always 0x0000
    CO_R: u8, // If the telegram is used for Connection request/Confirm,
    // the meaning of this field is CLASS+OPTION :
    //   Class (High 4 bits) + Option (Low 4 bits)
    //   Class : Always 4 (0100) but is ignored in input (RFC States this)
    //   Option : Always 0, also this in ignored.
    // If the telegram is used for Disconnect request,
    // the meaning of this field is REASON :
    //    1     Congestion at TSAP
    //    2     Session entity not attached to TSAP
    //    3     Address unknown (at TCP connect time)
    //  128+0   Normal disconnect initiated by the session
    //          entity.
    //  128+1   Remote transport entity congestion at connect
    //          request time
    //  128+3   Connection negotiation failed
    //  128+5   Protocol Error
    //  128+8   Connection request refused on this network
    //          connection
    // Parameter data : depending on the protocol implementation.
    // ISO 8073 define several type of parameters, but RFC 1006 recognizes only
    // TSAP related parameters and PDU size.  See RFC 0983 for more details.
    Params: TCOPT_Params,
    //Other params not used here, list only for completeness
    //ACK_TIME     	   = 0x85,  1000 0101 Acknowledge Time
    //RES_ERROR    	   = 0x86,  1000 0110 Residual Error Rate
    //PRIORITY           = 0x87,  1000 0111 Priority
    //TRANSIT_DEL  	   = 0x88,  1000 1000 Transit Delay
    //THROUGHPUT   	   = 0x89,  1000 1001 Throughput
    //SEQ_NR       	   = 0x8A,  1000 1010 Subsequence Number (in AK)
    //REASSIGNMENT 	   = 0x8B,  1000 1011 Reassignment Time
    //FLOW_CNTL    	   = 0x8C,  1000 1100 Flow Control Confirmation (in AK)
    //TPDU_SIZE    	   = 0xC0,  1100 0000 TPDU Size
    //SRC_TSAP     	   = 0xC1,  1100 0001 TSAP-ID / calling TSAP ( in CR/CC )
    //DST_TSAP     	   = 0xC2,  1100 0010 TSAP-ID / called TSAP
    //CHECKSUM     	   = 0xC3,  1100 0011 Checksum
    //VERSION_NR   	   = 0xC4,  1100 0100 Version Number
    //PROTECTION   	   = 0xC5,  1100 0101 Protection Parameters (user defined)
    //OPT_SEL            = 0xC6,  1100 0110 Additional Option Selection
    //PROTO_CLASS  	   = 0xC7,  1100 0111 Alternative Protocol Classes
    //PREF_MAX_TPDU_SIZE = 0xF0,  1111 0000
    //INACTIVITY_TIMER   = 0xF2,  1111 0010
    //ADDICC             = 0xe0   1110 0000 Additional Information on Connection Clearing
};
