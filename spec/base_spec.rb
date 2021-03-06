require File.dirname(__FILE__) + '/spec_helper'

describe "the Base32 implementation" do
  it "should be 16 characters by default" do
    ROTP::Base32.random_base32.length.should == 16
    ROTP::Base32.random_base32.should match /\A[a-z2-7]+\z/
  end
  it "should be allow a specific length" do
    ROTP::Base32.random_base32(32).length.should == 32
  end
  it "should correctly decode a string" do
    ROTP::Base32.decode("F").unpack('H*').first.should == "28"
    ROTP::Base32.decode("23").unpack('H*').first.should == "d6"
    ROTP::Base32.decode("234").unpack('H*').first.should == "d6f8"
    ROTP::Base32.decode("234A").unpack('H*').first.should == "d6f800"
    ROTP::Base32.decode("234B").unpack('H*').first.should == "d6f810"
    ROTP::Base32.decode("234BCD").unpack('H*').first.should == "d6f8110c"
    ROTP::Base32.decode("234BCDE").unpack('H*').first.should == "d6f8110c80"
    ROTP::Base32.decode("234BCDEFG").unpack('H*').first.should == "d6f8110c8530"
    ROTP::Base32.decode("234BCDEFG234BCDEFG").unpack('H*').first.should == "d6f8110c8536b7c0886429"
  end
end

describe "HOTP example values from the rfc" do
  it "should match the RFC" do
    # 12345678901234567890 in Bas32
    # GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ
    hotp = ROTP::HOTP.new("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    hotp.at(0).should ==(755224)
    hotp.at(1).should ==(287082)
    hotp.at(2).should ==(359152)
    hotp.at(3).should ==(969429)
    hotp.at(4).should ==(338314)
    hotp.at(5).should ==(254676)
    hotp.at(6).should ==(287922)
    hotp.at(7).should ==(162583)
    hotp.at(8).should ==(399871)
    hotp.at(9).should ==(520489)
  end
  it "should verify an OTP and now allow reuse" do
    hotp = ROTP::HOTP.new("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    hotp.verify(520489, 9).should be_true
    hotp.verify(520489, 10).should be_false
  end
  it "should output its provisioning URI" do
    hotp = ROTP::HOTP.new("wrn3pqx5uqxqvnqr")
    hotp.provisioning_uri('mark@percival').should == "otpauth://hotp/mark@percival?secret=wrn3pqx5uqxqvnqr&counter=0"
  end
end

describe "TOTP example values from the rfc" do
  it "should match the RFC" do
    totp = ROTP::TOTP.new("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    totp.at(1111111111).should ==(50471)
    totp.at(1234567890).should ==(5924)
    totp.at(2000000000).should ==(279037)
  end

  it "should match the Google Authenticator output" do
    totp = ROTP::TOTP.new("wrn3pqx5uqxqvnqr")
    Timecop.freeze(Time.at(1297553958)) do
      totp.now.should ==(102705)
    end
  end
  it "should match Dropbox 26 char secret output" do
    totp = ROTP::TOTP.new("tjtpqea6a42l56g5eym73go2oa")
    Timecop.freeze(Time.at(1378762454)) do
      totp.now.should ==(747864)
    end
  end
  it "should validate a time based OTP" do
    totp = ROTP::TOTP.new("wrn3pqx5uqxqvnqr")
    Timecop.freeze(Time.at(1297553958)) do
      totp.verify(102705).should be_true
    end
    Timecop.freeze(Time.at(1297553958 + 30)) do
      totp.verify(102705).should be_false
    end
  end


  it "should output its provisioning URI" do
    totp = ROTP::TOTP.new("wrn3pqx5uqxqvnqr")
    totp.provisioning_uri('mark@percival').should == "otpauth://totp/mark@percival?secret=wrn3pqx5uqxqvnqr"
  end
end
