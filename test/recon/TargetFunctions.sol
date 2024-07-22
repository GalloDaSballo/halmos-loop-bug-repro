// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter, SymTest {
    uint256 highestTokenId;



    function TwTAP_participate(address _participant, uint256 _amount, uint256 _duration) public {
        _duration = between(_duration, twTap.EPOCH_DURATION(), twTap.MAX_LOCK_DURATION());
        _amount = between(_amount, 0, tap.balanceOf(address(this)));
        uint256 newTokenId = twTap.participate(_participant, _amount, _duration);

        if (newTokenId > highestTokenId) {
            highestTokenId = newTokenId;
        }
    }

    struct Data {
        // TwTAP_exitPosition
        uint256 _tokenId;
        address _to;

        // TwTAP_participate
        address _participant;
        uint256 _amount; 
        uint256 _duration;
    }

    function check_counter_symbolic(
        bytes4[] memory selector,
        Data[] memory data
    ) public {
        vm.assume(selector.length == data.length);
        for (uint256 i = 0; i < selector.length; ++i) {
            // validate b4 after
            assumeValidSelector(selector[i]);
            // b4
            assumeSuccessfulCall(address(this), calldataFor(selector[i], data[i]));
            // after
        }

        // assert(0 > 1);
    }

    
    
    function assumeSuccessfulCall(address target, bytes memory data) internal {
        (bool success, ) = target.call(data);
        vm.assume(success);
    }

        ///@notice utility for returning the target functions selectors from the Counter contract
    function assumeValidSelector(bytes4 selector) internal {
        vm.assume(
            selector == this.TwTAP_participate.selector
        );
    }

    ///@notice utility for getting calldata for a given function's arguments
    function calldataFor(
        bytes4 selector,
        Data memory theData
    ) internal view returns (bytes memory) {
        if(selector == this.TwTAP_participate.selector) {
            return abi.encodeWithSelector(selector, theData._participant, theData._amount, theData._duration);
        }
    }
}
