requires 'Alien::Base', '0.005';

on 'configure' => sub {
    requires 'Alien::Base::ModuleBuild', '0.005';
};

on 'test' => sub {
    requires 'Test::More', '0.96';
};
