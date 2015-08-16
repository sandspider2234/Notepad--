import unittest
from enumRequiredRegisters import create_reg_list
from asmlib.consts import LARGE_REGISTERS_LIST


class TestProcList(unittest.TestCase):
    def setUp(self):
        self.reg_list = create_reg_list("ax bx cx dx al bl bl bl bl blahblahblah nh ah")
        self.null_string = create_reg_list("")

    def test_list_is_not_null(self):
        self.assertIsNotNone(self.reg_list)

    def test_list_is_less_than_four(self):
        self.assertLessEqual(len(self.reg_list), 4)

    def test_list_items_are_valid(self):
        for register in self.reg_list:
            self.assertIn(register, LARGE_REGISTERS_LIST)


suite = unittest.TestLoader().loadTestsFromTestCase(TestProcList)
unittest.TextTestRunner(verbosity=2).run(suite)
