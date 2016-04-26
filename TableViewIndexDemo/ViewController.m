//
//  ViewController.m
//  TableViewIndexDemo
//
//  Created by cqcityroot on 16/4/20.
//  Copyright © 2016年 cqmc. All rights reserved.
//

#import "ViewController.h"
#import "ContactCell.h"

static NSString *contactsCellIdentifier = @"contactsCell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSUInteger _lastContactsHash;
}

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *contacts;     // 存放排序后的内容
@property (strong, nonatomic) NSArray *indexList;    // 存放右侧索引

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
    [self updateContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateContent {
    
    NSArray *xings = @[@"赵",@"钱",@"孙",@"李",@"周",@"吴",@"郑",@"王",@"冯",@"陈",@"楚",@"卫",@"沈",@"杀",@"韩",@"#"];
    NSArray *ming1 = @[@"大",@"美",@"帅",@"应",@"超",@"海",@"江",@"湖",@"春",@"夏",@"秋",@"冬",@"上",@"左",@"有",@"纯"];
    NSArray *ming2 = @[@"强",@"好",@"领",@"亮",@"超",@"华",@"奎",@"海",@"工",@"青",@"红",@"潮",@"兵",@"垂",@"刚",@"山"];
    
    NSMutableArray *nameArr = [NSMutableArray array];
    
    for (int i = 0; i < 50; i++) {
        NSString *name = xings[arc4random_uniform((int)xings.count)];
        NSString *ming = ming1[arc4random_uniform((int)ming1.count)];
        name = [name stringByAppendingString:ming];
        if (arc4random_uniform(10) > 3) {
            NSString *ming = ming2[arc4random_uniform((int)ming2.count)];
            name = [name stringByAppendingString:ming];
        }
        [nameArr addObject:name];
    }
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    for (NSString *name in nameArr) {
        ContactEntity *contact = [[ContactEntity alloc] init];
        contact.name = name;
        contact.detail = @"测试标题";
        contact.avatarUrl = @"78268.jpg";
        [tmpArr addObject:contact];
    }
    
    self.contacts = tmpArr;
    
}

//set方法
- (void)setContacts:(NSArray *)objects {
    
    if (objects.hash == _lastContactsHash) {
        return;
    }
    
    _lastContactsHash = objects.hash;
    
    _contacts = [self arrayForSections:objects];
    [_tableView reloadData];
}

- (NSArray *)arrayForSections:(NSArray *)objects {
    
    // sectionTitlesCount 27 , A - Z + #
    SEL selector = @selector(name);
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    // section number
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    // Create 27 sections' data
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // Insert records
    for (id object in objects) {
        NSInteger sectionNumber = [collation sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    // sort in section
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        [mutableSections replaceObjectAtIndex:idx withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    
    // Remove empty sections && insert table data
    NSMutableArray *existTitleSections = [NSMutableArray array];
    for (NSArray *section in mutableSections) {
        if ([section count] > 0) {
            [existTitleSections addObject:section];
        }
    }
    
    // Remove empty sections Index in indexList
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allSections = [collation sectionIndexTitles];
    
    for (NSUInteger i = 0; i < [allSections count]; i++) {
        if ([mutableSections[ i ] count] > 0) {
            [existTitles addObject:allSections[ i ]];
        }
    }
    
    //create indexlist data array
    self.indexList = existTitles;
    
    return existTitleSections;
}

- (void)setupSubviews {
    
    // Header
    self.title = @"Contacts Index Demo";
    
    // setup tableview
    CGRect frame = self.view.bounds;
    self.tableView =
    [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [_tableView registerClass:[ContactCell class] forCellReuseIdentifier:contactsCellIdentifier];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_contacts count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_contacts[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell =
    [tableView dequeueReusableCellWithIdentifier:contactsCellIdentifier
                                    forIndexPath:indexPath];
    [cell updateContent:_contacts[ indexPath.section ][ indexPath.row ]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _indexList[ section ];
}

//添加tableview 右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
