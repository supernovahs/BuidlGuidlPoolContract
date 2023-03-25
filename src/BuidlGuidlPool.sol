// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/utils/Address.sol";
// @title BuidlGuidlPool
// @author supernovahs.eth <github.com/supernovahs>
// @notice This contract is a pool for the BuidlGuidl incentivization program.
contract BuidlGuidlPool {

  // Storage
  mapping (address => Stream) public stream_map;

  // Constants 
  address public immutable BUIDL_GUIDL;

   // Events
  event Withdraw( address indexed to, uint256 amount, string reason );

// Stream Struct for inidvidual builders
  struct Stream {
    uint cap ;
    uint frequency;
    uint last;
    uint totalStream;
  }
  

  //enum 
  enum Type{
    DamageDealer,
    FullStack
  }

   // Modifiers
    modifier onlyBuidlGuidl() {
        require(msg.sender == BUIDL_GUIDL, "Only BuidlGuidl can call this function");
        _;
    }

/// @notice Sweep all funds to BuidlGuidl
/// @dev Only BuidlGuidl can call this function
/// @dev Emergency in nature.
    function Sweep() external onlyBuidlGuidl {
       (bool s,) = BUIDL_GUIDL.call{value: address(this).balance}("");
         require(s, "Sweep failed");
    }


/// @notice Create a new stream
/// @param stream The type of stream
/// @param _builder The address of the _builder
/// @param _startsFull Whether the stream starts full or not
/// @param _frequency The frequency of the stream
/// @dev Only called by BuidlGuidl
    function StreamBuilder(Type stream, uint  _totalStream, address _builder,bool _startsFull, uint _frequency) external onlyBuidlGuidl {
        require(stream_map[_builder].cap ==0);
        stream_map[_builder].cap = stream == Type.DamageDealer ? 1.5 ether : 0.5 ether;
        stream_map[_builder].frequency = _frequency;
        stream_map[_builder].last = _startsFull ? (block.timestamp - _frequency) : block.timestamp;
        if(_totalStream !=0){
        stream_map[_builder].totalStream = _totalStream;
        }
    }


/// @notice Get the current balance of the stream
/// @param _builder The address of the _builder
    function streamBalance(address _builder) public  view returns(uint){
        Stream memory  stream = stream_map[_builder];
        uint last = stream.last;
        uint frequency = stream.frequency;
        uint cap = stream.cap;
         if(block.timestamp-last > frequency){
            return cap;
        }
        return (cap * (block.timestamp-last)) / frequency;
    }

/// @notice Withdraw funds from the stream
/// @param _amount The amount of funds to withdraw
/// @param reason The reason for the withdrawal
    function streamWithdraw(uint _amount,string memory reason) external {
        Stream memory  stream = stream_map[msg.sender];
        uint last = stream.last;
        uint frequency = stream.frequency;
        uint totalAmountCanWithdraw = streamBalance(msg.sender);
        uint _totalStream = stream.totalStream;
        require(totalAmountCanWithdraw>=_amount,"not enough in the stream");
        uint cappedLast = block.timestamp - frequency;

         if(last < cappedLast){
            last = cappedLast;
        }

        stream_map[msg.sender].last = last + ((block.timestamp - last) * _amount / totalAmountCanWithdraw);
        emit Withdraw( msg.sender, _amount, reason );
        if(_totalStream !=0){
        require(_totalStream - _amount >=1,"not enough in the stream"); // 1 wei will always be maintained to prevent converting finite streams to infinite.
        stream_map[msg.sender].totalStream = _totalStream - _amount;
        }
        Address.sendValue(payable(msg.sender), _amount);
    }


/// @notice Convert a finite stream to an infinite stream
/// @param _builder The address of the _builder
/// @dev Only called by BuidlGuidl
    function convertFiniteStreamToInfinite(address _builder) external onlyBuidlGuidl{
        Stream memory  stream = stream_map[_builder];
        uint _totalStream = stream.totalStream;
        require(_totalStream !=0,"stream is already infinite");
        stream_map[_builder].totalStream = 0;
    }

/// @dev Receive Ether Freely
    receive() external payable {}


// Constructor 

constructor(address _BUIDL_GUIDL) {
    BUIDL_GUIDL = _BUIDL_GUIDL;
  }

}
